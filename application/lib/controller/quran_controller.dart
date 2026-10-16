import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/model/response/juz_list_model.dart';
import 'package:nazar_e_alam/data/model/response/sifat_name_details_model.dart';
import 'package:nazar_e_alam/data/model/response/sifat_name_list_model.dart';
import 'package:nazar_e_alam/data/model/response/sura_detile_model.dart';
import 'package:nazar_e_alam/data/model/response/sura_list_model.dart';
import 'package:nazar_e_alam/data/repository/sifatname_list_repo.dart';

class QuranController extends GetxController implements GetxService {
  final QuranRepo quranRepo;
  QuranController({required this.quranRepo});
  @override
  void onInit() {
    // fetchSifatNameListData();
    super.onInit();
  }

// local variable
  RxBool isSifatNameListLoading = false.obs;
  SifatNameListModel? sifatNameApiData;

// get dua list form here
  Future<void> fetchSifatNameListData() async {
    try {
      isSifatNameListLoading(true);

      final response = await quranRepo.getSifatNameRepo();

      if (response.statusCode == 200) {
        sifatNameApiData = SifatNameListModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isSifatNameListLoading(false);
      update();
    }
  }

  RxBool isSifatNameDetailsLoading = false.obs;
  SifatNameDetailsModel? sifatnameDetailsApidata;

// get dua details function
  Future<void> fetchSifatNameDetailsData({String? sifatNameId}) async {
    try {
      isSifatNameDetailsLoading(true);

      final response =
          await quranRepo.getSifatNameDetailsRepo(sifatNameId.toString());

      if (response.statusCode == 200) {
        sifatnameDetailsApidata = SifatNameDetailsModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isSifatNameDetailsLoading(false);
      update();
    }
  }

  // local variable
  SuraListModel? suraListApiData;
  SuraDetaileModel? suraDetaileApiData;
  JuzListModel? juzListApiData;

  RxBool isJuzListLoading = false.obs;
  RxBool isSuraListLoading = false.obs;
  RxBool isSuraDetaileLoading = false.obs;
  int? suraNumber;

// get sura list function
  Future<void> fetchSuraListData({String? translatorId}) async {
    try {
      isSuraListLoading(true);
      final prefs = await SharedPreferences.getInstance();
      var selectedTranslatorId =
          translatorId ?? prefs.getString('selectedTranslatorId') ?? 1;

      final response =
          await quranRepo.getSuraListRepo(selectedTranslatorId.toString());

      if (response.statusCode == 200) {
        suraListApiData = SuraListModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isSuraListLoading(false);
      update();
    }
  }

// get sura detail function
  Future<void> fetchSuraDetaileData(
      {String? suraId, String? translatorId}) async {
    try {
      isSuraDetaileLoading(true);
      update();
      final prefs = await SharedPreferences.getInstance();
      var selectedTranslatorId =
          translatorId ?? prefs.getString('selectedTranslatorId') ?? 1;

      final response = await quranRepo.getSuraDetailsRepo(
          suraId.toString(), selectedTranslatorId.toString());

      if (response.statusCode == 200) {
        suraDetaileApiData = SuraDetaileModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isSuraDetaileLoading(false);
      update();
    }
  }

// get juz list form here
  Future<void> fetchJuzListData({String? translatorId}) async {
    try {
      isJuzListLoading(true);
      final prefs = await SharedPreferences.getInstance();
      var selectedTranslatorId =
          translatorId ?? prefs.getString('selectedTranslatorId') ?? 1;

      final response =
          await quranRepo.getJuzListRepo(selectedTranslatorId.toString());

      if (response.statusCode == 200) {
        juzListApiData = JuzListModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isJuzListLoading(false);
      update();
    }
  }
}
