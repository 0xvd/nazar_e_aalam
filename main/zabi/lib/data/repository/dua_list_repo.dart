// ignore_for_file: strict_top_level_inference

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class DuaRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DuaRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getDuaListRepo() async {
    return await apiClient.getData(AppConstants.DUA_LIST);
  }

  Future<Response> getDuaDetailsRepo(duaId) async {
    return await apiClient.getData(AppConstants.DUA_DETAILES + duaId);
  }
}
