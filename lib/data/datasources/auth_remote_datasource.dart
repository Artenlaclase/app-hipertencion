import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/services/auth_token_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(Map<String, dynamic> data);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>> refreshToken();
  Future<UserModel> getMe();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<void> onboarding(Map<String, dynamic> data);
  Future<void> forgotPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post('/forgot-password', body: {'email': email});
  }

  final ApiClient apiClient;
  final AuthTokenService authTokenService;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.authTokenService,
  });

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiConstants.register, body: data);
    final token = response['access_token'] ?? response['token'];
    if (token != null) {
      await authTokenService.saveToken(token);
    }
    return response;
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );
    final token = response['access_token'] ?? response['token'];
    if (token != null) {
      await authTokenService.saveToken(token);
    }
    return response;
  }

  @override
  Future<void> logout() async {
    await apiClient.post(ApiConstants.logout);
    await authTokenService.clearAuth();
  }

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    final response = await apiClient.post(ApiConstants.refresh);
    final token = response['access_token'] ?? response['token'];
    if (token != null) {
      await authTokenService.saveToken(token);
    }
    return response;
  }

  @override
  Future<UserModel> getMe() async {
    final response = await apiClient.get(ApiConstants.me);
    final userData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put(ApiConstants.profile, body: data);
    final userData =
        response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
    return UserModel.fromJson(userData);
  }

  @override
  Future<void> onboarding(Map<String, dynamic> data) async {
    await apiClient.post(ApiConstants.onboarding, body: data);
    await authTokenService.setOnboardingCompleted(true);
  }
}
