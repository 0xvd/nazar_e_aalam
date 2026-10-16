// ignore_for_file: strict_top_level_inference

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class DonationRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DonationRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getDonationCategoryLisRepo() async {
    return await apiClient.getData(AppConstants.DONATION_Category);
  }

  Future<Response> getPaymentMethodListRepo() async {
    return await apiClient.getData(AppConstants.PAYMENT_METHODS);
  }

  Future<Response> getDonatedListLisRepo(
      selectedEmailName, currentTimeZone) async {
    return await apiClient.getData(
        "${AppConstants.DONATED_LIST}?email=$selectedEmailName&timezone=$currentTimeZone");
  }

  Future<Response> addDonationRepo({required dynamic map}) async {
    return await apiClient.postData(AppConstants.DONATION_STORE, map);
  }
}
