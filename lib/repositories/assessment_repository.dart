import '../models/assessment/mock_test_models.dart';
import '../models/assessment/problem_model.dart';
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

  Future<ApiResponse<PreparationPacksResponseModel>> getPreparationPacks({int page = 1, int limit = 12}) {
    return _api.get<PreparationPacksResponseModel>(
      ApiEndpoints.prepPacks,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (json) {
        final dataMap = json as Map<String, dynamic>;
        final rawList = dataMap['data'] as List<dynamic>? ?? [];
        final rawPagination = dataMap['pagination'] as Map<String, dynamic>? ?? {};

        final packsList = rawList
            .map((e) => PreparationPackModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final pagination = PreparationPackPaginationModel.fromJson(rawPagination);

        return PreparationPacksResponseModel(
          packs: packsList,
          pagination: pagination,
        );
      },
    );
  }

  Future<ApiResponse<ProblemResponseModel>> getProblems({
    int page = 1,
    int limit = 10,
    String search = '',
    bool isPublished = true,
  }) {
    return _api.get<ProblemResponseModel>(
      ApiEndpoints.problems,
      queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
        'isPublished': isPublished,
      },
      fromJson: (json) {
        final dataMap = json as Map<String, dynamic>;
        
        // Handle standard envelope vs direct arrays
        final rawList = dataMap['data'] as List<dynamic>? ?? [];
        final rawPagination = dataMap['pagination'] as Map<String, dynamic>? ?? {};

        final problemsList = rawList
            .map((e) => ProblemModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final pagination = ProblemPaginationModel.fromJson(rawPagination);

        return ProblemResponseModel(
          problems: problemsList,
          pagination: pagination,
        );
      },
    );
  }

  Future<ApiResponse<ProblemDetailModel>> getProblemDetail(String id) {
    return _api.get<ProblemDetailModel>(
      "${ApiEndpoints.problems}/$id",
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final data = map['data'] as Map<String, dynamic>? ?? {};
        return ProblemDetailModel.fromJson(data);
      },
    );
  }
}
