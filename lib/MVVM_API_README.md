# MVVM API Integration Structure

This document explains the clean, minimal MVVM structure for API integration in your Flutter project.

## 📁 Folder Structure

```
lib/
├── models/                    # API response models
│   └── student_model.dart
├── services/                  # API calls and HTTP operations
│   ├── base_api_service.dart   # Common HTTP methods
│   └── student_api_service.dart # Student-specific endpoints
├── viewmodels/                # Business logic and state management
│   └── student_viewmodel.dart
├── views/                     # UI screens (existing)
│   └── ...your existing screens...
└── examples/                   # Integration examples
    └── api_integration_example.dart
```

## 🎯 Purpose of Each Layer

### 1. Models (`models/`)
- **Purpose**: Define data structures for API responses
- **Contains**: JSON serialization/deserialization logic
- **Example**: `StudentModel` with `fromJson()` and `toJson()`

### 2. Services (`services/`)
- **Purpose**: Handle HTTP requests and API communication
- **BaseApiService**: Common HTTP methods (GET, POST, PUT, DELETE)
- **Specific Services**: Feature-specific API endpoints (e.g., `StudentApiService`)

### 3. ViewModels (`viewmodels/`)
- **Purpose**: Business logic, state management, and API coordination
- **Contains**: Methods that UI calls, handles loading/error states
- **Pattern**: Extends `ChangeNotifier` for state updates

### 4. Views (`views/`)
- **Purpose**: UI components and screens
- **Pattern**: Uses `Consumer` or `Provider.of()` to access ViewModels
- **Responsibility**: Display data and handle user interactions

## 🚀 Quick Start Integration

### Step 1: Add API Endpoint
```dart
// In student_api_service.dart
static Future<StudentModel> getStudentProfile(String studentId) async {
  final response = await BaseApiService.get('students/$studentId');
  return StudentModel.fromJson(jsonDecode(response.body));
}
```

### Step 2: Update ViewModel
```dart
// In student_viewmodel.dart
Future<void> fetchStudentProfile(String studentId) async {
  _setLoading(true);
  try {
    final student = await StudentApiService.getStudentProfile(studentId);
    _student = student;
    notifyListeners();
  } catch (e) {
    _setError(e.toString());
  } finally {
    _setLoading(false);
  }
}
```

### Step 3: Update UI
```dart
// In your screen widget
Consumer<StudentViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (viewModel.error != null) {
      return Text('Error: ${viewModel.error}');
    }
    
    return StudentInfo(student: viewModel.student!);
  },
)
```

## 📝 Adding New Features

### 1. Create Model
```dart
// models/new_feature_model.dart
class NewFeatureModel {
  final String id;
  final String name;
  
  NewFeatureModel({required this.id, required this.name});
  
  factory NewFeatureModel.fromJson(Map<String, dynamic> json) {
    return NewFeatureModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

### 2. Create Service
```dart
// services/new_feature_api_service.dart
import '../models/new_feature_model.dart';
import 'base_api_service.dart';

class NewFeatureApiService {
  static Future<List<NewFeatureModel>> getAll() async {
    final response = await BaseApiService.get('new-features');
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => NewFeatureModel.fromJson(item)).toList();
  }
  
  static Future<NewFeatureModel> create(Map<String, dynamic> data) async {
    final response = await BaseApiService.post('new-features', data);
    return NewFeatureModel.fromJson(jsonDecode(response.body));
  }
}
```

### 3. Create ViewModel
```dart
// viewmodels/new_feature_viewmodel.dart
import '../models/new_feature_model.dart';
import '../services/new_feature_api_service.dart';

class NewFeatureViewModel extends ChangeNotifier {
  List<NewFeatureModel> _items = [];
  bool _isLoading = false;
  String? _error;
  
  List<NewFeatureModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> fetchItems() async {
    _setLoading(true);
    try {
      _items = await NewFeatureApiService.getAll();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // ... other methods
}
```

## 🔧 Best Practices

1. **Error Handling**: Always wrap API calls in try-catch
2. **Loading States**: Show loading indicators during async operations
3. **Null Safety**: Use null-aware operators and provide defaults
4. **State Management**: Use `notifyListeners()` for UI updates
5. **Separation of Concerns**: Keep UI, business logic, and data separate

## 📱 Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0          # For HTTP requests
  provider: ^6.0.0         # For state management
```

## 🎨 UI Integration Tips

1. **Use Consumer**: For rebuilds when ViewModel state changes
2. **Handle Loading**: Show loading spinners during API calls
3. **Show Errors**: Display user-friendly error messages
4. **Refresh Data**: Implement pull-to-refresh functionality
5. **Optimistic Updates**: Update UI immediately, then sync with API

## 🚨 Common Patterns

### API Call Pattern
```dart
Future<void> apiCall() async {
  _setLoading(true);
  _clearError();
  
  try {
    final result = await SomeApiService.getData();
    _data = result;
    notifyListeners();
  } catch (e) {
    _setError(e.toString());
  } finally {
    _setLoading(false);
  }
}
```

### UI Consumption Pattern
```dart
Consumer<ViewModel>(
  builder: (context, viewModel, child) {
    return Column(
      children: [
        if (viewModel.isLoading) 
          CircularProgressIndicator(),
        if (viewModel.error != null)
          Text(viewModel.error!),
        if (viewModel.data != null)
          DataWidget(data: viewModel.data!),
      ],
    );
  },
)
```

This structure provides a solid foundation for building scalable, maintainable Flutter applications with clean API integration.
