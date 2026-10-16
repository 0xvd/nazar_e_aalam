// ignore_for_file: strict_top_level_inference

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class DhikrRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DhikrRepo({required this.sharedPreferences, required this.apiClient});
 //Dikir List
  Future<Response> getDikirListRepo() async {
    return await apiClient.getData(AppConstants.DIKIR_LIST);
  }

 //Dikir Details
  Future<Response> getDikirDetailsRepo(dikirId) async {
    return await apiClient.getData(AppConstants.DIKIR_DETAILES + dikirId);
  }
}
