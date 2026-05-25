import '../models/assessment/mock_test_models.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class AssessmentRepository {
  final NetworkAPIManager _api;

  AssessmentRepository(this._api);

  Future<ApiResponse<List<CompanyTagModel>>> getCompanies() {
    return _api.get<List<CompanyTagModel>>(
      ApiEndpoints.preparationCompanies,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => CompanyTagModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<AssessmentStatsModel>> getStats() {
    return _api.get<AssessmentStatsModel>(
      ApiEndpoints.assessmentStats,
      fromJson: (json) => AssessmentStatsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<CurrentAssessmentModel>> getCurrentAssessment() {
    return _api.get<CurrentAssessmentModel>(
      ApiEndpoints.assessmentCurrent,
      fromJson: (json) => CurrentAssessmentModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<AvailableTestModel>>> getAvailableTests({String? company}) {
    return _api.get<List<AvailableTestModel>>(
      ApiEndpoints.assessmentList,
      queryParameters: company != null ? {'company': company} : null,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => AvailableTestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<List<PreparationPackModel>>> getPreparationPacks() {
    return _api.get<List<PreparationPackModel>>(
      ApiEndpoints.preparationPacks,
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => PreparationPackModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
