# GyaanPlant - Flutter MVVM Architecture Demo

A clean, scalable Flutter project demonstrating MVVM (Model-View-ViewModel) architecture with go_router for navigation and Provider for state management.

## 🏗️ Project Structure

```
lib/
│
├── core/
│   ├── constants/        # App-wide constants
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_styles.dart
│   └── utils/            # Helper utilities
│       ├── helpers.dart
│       └── validators.dart
│
├── data/
│   ├── models/           # Data models
│   │   └── user_model.dart
│   └── services/         # API and local storage
│       ├── api_service.dart
│       └── local_storage_service.dart
│
├── viewmodels/           # Business logic (MVVM)
│   └── home_viewmodel.dart
│
├── views/
│   ├── screens/          # Full pages
│   │   ├── home_screen.dart
│   │   └── second_screen.dart
│   └── widgets/          # Reusable UI components
│
├── routes/
│   └── app_router.dart   # GoRouter configuration
│
└── main.dart            # App entry point
```

## 🚀 Features

- **MVVM Architecture**: Clean separation of concerns with Model-View-ViewModel pattern
- **GoRouter**: Modern declarative routing with nested routes and navigation
- **Provider**: Simple and effective state management with ChangeNotifier
- **Clean Code**: Well-structured, commented, and maintainable code
- **Theme Support**: Light and dark theme support with Material 3
- **Error Handling**: Proper error handling and loading states
- **Responsive Design**: Clean UI that works across different screen sizes

## 📦 Dependencies

- `go_router`: ^14.2.7 - Declarative routing
- `provider`: ^6.1.2 - State management
- `http`: ^1.2.2 - HTTP requests
- `shared_preferences`: ^2.3.2 - Local storage

## 🎯 Key Components

### Core Layer
- **Constants**: Centralized colors, strings, and styles
- **Utils**: Reusable helper functions and validators

### Data Layer
- **Models**: Data classes with JSON serialization
- **Services**: API client and local storage abstraction

### ViewModels Layer
- **Business Logic**: State management and data operations
- **ChangeNotifier**: Reacts to state changes and notifies UI

### Views Layer
- **Screens**: Full page implementations
- **Widgets**: Reusable UI components

### Routes Layer
- **Navigation**: Centralized routing configuration
- **GoRouter**: Modern navigation with type safety

## 🔄 MVVM Flow

1. **View** (UI) listens to **ViewModel** state changes
2. User interactions trigger **ViewModel** methods
3. **ViewModel** processes logic and updates state
4. **ViewModel** notifies listeners of state changes
5. **View** rebuilds with new state

## 🎨 Navigation

The app uses GoRouter for navigation:

```dart
// Navigate to second screen
AppRouter.goToSecondScreen(context);

// Go back
AppRouter.goBack(context);

// Navigate to home
AppRouter.goToHome(context);
```

## 🛠️ Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. Build for production:
   ```bash
   flutter build apk
   ```

## 📱 Screens

### Home Screen
- Welcome message with dynamic content
- Counter demonstration with MVVM
- Navigation to second screen
- Async operation example
- Refresh functionality

### Second Screen
- Architecture benefits showcase
- Feature cards
- Navigation options

## 🧪 Testing

The project structure supports easy testing:

- **Unit Tests**: Test ViewModels and business logic
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

## 🎯 Best Practices Demonstrated

- **Separation of Concerns**: Clear boundaries between layers
- **Dependency Injection**: Service locator pattern
- **Error Handling**: Proper error states and user feedback
- **State Management**: Reactive programming with Provider
- **Code Organization**: Logical folder structure
- **Documentation**: Comprehensive code comments

## 🚀 Next Steps

This is a starter template. You can extend it by:

1. Adding more screens and navigation routes
2. Implementing actual API endpoints
3. Adding authentication
4. Integrating databases
5. Adding animations and transitions
6. Implementing unit and widget tests

## 📄 License

This project is open source and available under the MIT License.
