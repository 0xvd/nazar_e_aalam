import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class WallpaperRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  WallpaperRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getWallpaperLisRepo() async {
    return await apiClient.getData(AppConstants.WALLPAPER_LIST);
  }
}
