import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class QuranSettingsRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  QuranSettingsRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getHaramFoodRepo() async {
    return await apiClient.getData(AppConstants.HARAM_FOOD_LIST);
  }

  Future<Response> getTranslatorRepo() async {
    return await apiClient.getData(AppConstants.TRANSLATOR);
  }

  Future<Response> getMosqueSettingsRepo() async {
    return await apiClient.getData(AppConstants.MOSQUE_SETTINGS);
  }
}
