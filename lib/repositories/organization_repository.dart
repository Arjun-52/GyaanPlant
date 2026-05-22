import '../models/student_role_models/organization_model.dart';
import '../network/api_endpoints.dart';
import '../network/api_manager.dart';
import '../network/api_response.dart';

class OrganizationRepository {
  final NetworkAPIManager _api;

  OrganizationRepository(this._api);

  Future<ApiResponse<List<Organization>>> getOrganizations() {
    return _api.get<List<Organization>>(
      ApiEndpoints.organizations,
      queryParameters: {
        'page': 1,
        'limit': 20,
        'industry': 'IT',
        'type': 'MNC',
        'sort': 'name',
      },
      fromJson: (json) {
        // Debug logs as requested
        print(json);

        final map = json as Map<String, dynamic>;
        final list = (map['data'] ?? []) as List<dynamic>;
        final companies = list
            .map((e) => Organization.fromJson(e as Map<String, dynamic>))
            .toList();

        print("Companies fetched: ${companies.length}");
        for (var company in companies) {
          print(company.name);
        }

        return companies;
      },
    );
  }
}
