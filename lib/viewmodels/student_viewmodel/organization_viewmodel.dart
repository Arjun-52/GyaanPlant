import 'package:flutter/material.dart';
import 'package:gyaanplant/core/utils/app_logger.dart';
import '../../data/services/api_service.dart';
import '../../models/student_role_models/organization_model.dart';

class OrganizationViewModel extends ChangeNotifier {
  static const _tag = 'OrganizationViewModel';

  final _apiService = ApiService();

  List<Organization> companies = [];
  bool isLoading = false;
  String? selectedCompany;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> fetchOrganizations() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.organization.getOrganizations();
      if (response.isSuccess) {
        companies = response.data ?? [];
        errorMessage = null;
      } else {
        errorMessage = response.error?.message ?? 'Unable to load companies';
        companies = [];
      }
    } catch (e, st) {
      errorMessage = 'Unable to load companies';
      AppLogger.error(_tag, 'Failed to fetch organizations', e, st);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCompany(String? companyName) {
    if (selectedCompany == companyName) {
      selectedCompany = null; // deselect if already selected
    } else {
      selectedCompany = companyName;
    }
    notifyListeners();
  }
}
