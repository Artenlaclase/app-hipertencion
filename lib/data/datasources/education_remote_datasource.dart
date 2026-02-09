import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/education_content_model.dart';

abstract class EducationRemoteDataSource {
  Future<List<EducationContentModel>> getContents({String? topic, String? level});
  Future<EducationContentModel> getContent(String id);
}

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final ApiClient apiClient;

  EducationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EducationContentModel>> getContents({
    String? topic,
    String? level,
  }) async {
    final queryParams = <String, String>{};
    if (topic != null) queryParams['topic'] = topic;
    if (level != null) queryParams['level'] = level;
    final response = await apiClient.get(
      ApiConstants.educationalContents,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final List<dynamic> data = response is Map && response.containsKey('data')
        ? response['data']
        : (response is List ? response : []);
    return data.map((json) => EducationContentModel.fromJson(json)).toList();
  }

  @override
  Future<EducationContentModel> getContent(String id) async {
    final response = await apiClient.get('${ApiConstants.educationalContents}/$id');
    final contentData = response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return EducationContentModel.fromJson(contentData);
  }
}
