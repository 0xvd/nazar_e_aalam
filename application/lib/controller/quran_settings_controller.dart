// ignore_for_file: strict_top_level_inference

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nazar_e_alam/data/model/response/haram_food_list_model.dart';
import 'package:nazar_e_alam/data/model/response/mosque_settings_model.dart';
import 'package:nazar_e_alam/data/model/response/translator_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/data/repository/quran_setting_repo.dart';

class SettingsController extends GetxController implements GetxService {
  final QuranSettingsRepo quranSettingRepo;
  SettingsController({required this.quranSettingRepo});
  @override
  void onInit() {
    super.onInit();
    getSuraTranslationApiData();
    loadSavedApiTranslateDropdownValue();
    getArabicFontSizeFromLocalStorage();
    getTranslateFontSizeFromLocalStorage();
    loadArabicFontPreference();
  }

  //==============================//
  //   Arabic Font size part      //
  //=============================//

  RxDouble arabicFontSize = 22.0.obs; // Default font size
  final String arabicFontSizeKey = "arabic_font_size_key";

  void changeArabicFontSize(double newSize) {
    arabicFontSize.value = newSize;
    saveArabicFontSizeToLocalStorage(newSize);
  }

  void saveArabicFontSizeToLocalStorage(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(arabicFontSizeKey, size);
  }

  void getArabicFontSizeFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedFontSize = prefs.getDouble(arabicFontSizeKey);
    if (storedFontSize != null) {
      arabicFontSize.value = storedFontSize;
    }
  }

  //==============================//
  //   Translate Font size part   //
  //=============================//

  RxDouble translateFontSize = 14.0.obs; // Default font size
  final String translateFontSizeKey = "tanslate_font_size_key";

  void changeTranslateFontSize(double newSize) {
    translateFontSize.value = newSize;
    saveTranslateFontSizeToLocalStorage(newSize);
  }

  void saveTranslateFontSizeToLocalStorage(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(translateFontSizeKey, size);
  }

  void getTranslateFontSizeFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedFontSize = prefs.getDouble(translateFontSizeKey);
    if (storedFontSize != null) {
      translateFontSize.value = storedFontSize;
    }
  }

  //=================================//
  //    Change Arabic font part     //
  //===============================//

  static const String selectedFontKey = 'selectedFont';

  // Reactive state variables
  RxBool isSelectedFontLoading = false.obs;
  RxString selectedFont = 'Scheherazade New'.obs;

  // All available fonts in one place
  final List<String> availableFonts = const [
    "Scheherazade New",
    'Amiri',
    'AmiriQuran',
    'Lateef',
    'NotoKufiArabic',
    'NotoNaskhArabic',
    'NotoNastaliqUrdu',
    'NotoSansArabic',
    'ReadexPro',
  ];

  // Computed getter: reactive TextStyle for Arabic text
  TextStyle get selectedArabicFont =>
      TextStyle(fontFamily: selectedFont.value, fontWeight: FontWeight.w500);

  // -----------------------------
  // FONT MANAGEMENT METHODS
  // -----------------------------

  Future<void> changeArabicFont(String font) async {
    if (font == selectedFont.value) return;

    isSelectedFontLoading(true);
    selectedFont.value = font;
    await _saveArabicFontPreference(font);

    // Simulate short load animation
    await Future.delayed(const Duration(milliseconds: 400));
    isSelectedFontLoading(false);
  }

  Future<void> loadArabicFontPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final font = prefs.getString(selectedFontKey);
    if (font != null && availableFonts.contains(font)) {
      selectedFont.value = font;
    }
  }

  Future<void> _saveArabicFontPreference(String font) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedFontKey, font);
  }
  //=================================//
  //    Translate Dropdown part     //
  //===============================//

  RxBool isTranslateLoading = false.obs;
  RxBool isTranslateDropdownLoading = false.obs;

  List<Map<String, dynamic>> allTranslationNameList = [];
  var translateDropdown = ''.obs;
  var selectedTranslatorId = ''.obs;
  TranslatorModel? translatorApiData;

  Future<void> getSuraTranslationApiData() async {
    try {
      isTranslateLoading(true);
      update();

      final String response = await rootBundle.loadString(
        'assets/quran/translators.json',
      );

      final data = json.decode(response);
      translatorApiData = TranslatorModel.fromJson(data);

      var translationlength = translatorApiData!.data!;

      for (var i = 0; i < translationlength.length; i++) {
        Map<String, dynamic> translationData = {
          'id': translationlength[i].id,
          'full_name': translationlength[i].fullName,
          'short_name': translationlength[i].shortName,
          'language': translationlength[i].language,
          'lang_code': translationlength[i].languageCode,
        };

        allTranslationNameList.add(translationData);

        translateDropdown.value = translateDropdown.value == ''
            ? "${allTranslationNameList[0]["id"]}. ${allTranslationNameList[0]["full_name"]}"
            : translateDropdown.value;
      }
    } catch (e) {
      rethrow;
    } finally {
      isTranslateLoading(false);
      update();
    }
  }

  // local variable
  RxBool isDuaListLoading = false.obs;
  HaramFoodListModel? haramFoodListApiData;

  // get dua list form here
  Future<void> fetchHaramFoodListData({String? translatorId}) async {
    try {
      isDuaListLoading(true);

      final response = await quranSettingRepo.getHaramFoodRepo();

      if (response.statusCode == 200) {
        haramFoodListApiData = HaramFoodListModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isDuaListLoading(false);
      update();
    }
  }

  // local variable
  RxBool isMosqueSettingsLoading = false.obs;
  MosqueSettingsModel? mosqueSettingsApiData;

  // get juz list form here
  Future<void> fetchMosqueSettingsData({String? translatorId}) async {
    try {
      isMosqueSettingsLoading(true);

      final response = await quranSettingRepo.getMosqueSettingsRepo();
update();
      if (response.statusCode == 200) {
        mosqueSettingsApiData = MosqueSettingsModel.fromJson(response.body);
        Get.find<HomeLayoutController>().applyApiValue(
          mosqueSettingsApiData?.data?.homeLayout,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isMosqueSettingsLoading(false);
      update();
    }
  }

  void loadSavedApiTranslateDropdownValue() async {
    final prefs = await SharedPreferences.getInstance();
    translateDropdown.value =
        prefs.getString('apiTranslateDropdown') ?? translateDropdown.value;
    selectedTranslatorId.value =
        prefs.getString('selectedTranslatorId') ?? selectedTranslatorId.value;

    update();
    if (kDebugMode) {
      print("apiTranslateDropdown: ${translateDropdown.value}");
      print("selectedTranslatorId: ${selectedTranslatorId.value}");
    }
  }

  void saveTranslateDropdownValue(newValue, selectedId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiTranslateDropdown', newValue);
    await prefs.setString('selectedTranslatorId', selectedId);
    update();
  }

  void updateTranslateDropdownValue(newValue, selectedId) {
    isTranslateDropdownLoading(true);
    translateDropdown.value = newValue;
    selectedTranslatorId.value = selectedId;
    saveTranslateDropdownValue(newValue, selectedId);
    Future.delayed(const Duration(seconds: 2), () {
      isTranslateDropdownLoading(false);
    });
    update();
  }

  //
}
