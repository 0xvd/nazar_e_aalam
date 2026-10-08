// ignore_for_file: strict_top_level_inference

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class QuranRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  QuranRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getSifatNameRepo() async {
    return await apiClient.getData(AppConstants.SIFAT_NAME_LIST);
  }

  Future<Response> getSifatNameDetailsRepo(sifatNameId) async {
    return await apiClient
        .getData(AppConstants.SIFAT_NAME_DETAILES + sifatNameId);
  }

  Future<Response> getSuraListRepo(selectedTranslatorId) async {
    return await apiClient.getData(AppConstants.SURA_LIST +
        AppConstants.TRANSLATOR_ID +
        selectedTranslatorId);
  }

  Future<Response> getSuraDetailsRepo(suraId, selectedTranslatorId) async {
    return await apiClient.getData(AppConstants.SURA_Detaile +
        suraId +
        AppConstants.TRANSLATOR_ID +
        selectedTranslatorId);
  }

  Future<Response> getJuzListRepo(selectedTranslatorId) async {
    return await apiClient.getData(AppConstants.JUZ_LIST +
        AppConstants.TRANSLATOR_ID +
        selectedTranslatorId);
  }
}
