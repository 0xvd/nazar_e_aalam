// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/model/response/juz_list_model.dart';
import 'package:nazar_e_alam/data/model/response/offline_sura_model.dart';
import 'package:nazar_e_alam/data/model/response/sura_detile_model.dart';
import 'package:nazar_e_alam/helper/offline_quran_loader.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/offline_surah_detail_screen.dart';

class OfflineQuranController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<OfflineSurahListModel> surahList = <OfflineSurahListModel>[].obs;

  Future<void> loadSurahList() async {
    print('Loading offline surah list...');
    try {
      final String response = await rootBundle.loadString(
        'assets/quran/surah_list.json',
      );
      final data = json.decode(response);
      final List surahData = data['data'];
      surahList.value = surahData
          .map((e) => OfflineSurahListModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error loading surah list: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Add other methods to load surah details, ayahs, etc. as needed

  RxBool isSurahDetailsLoading = true.obs;

  SuraDetaileModel? suraDetailsApiData;

  Future<void> loadSurahDetails({
    required int surahNumber,
    String? translatorId,
  }) async {
    try {
      // suraDetailsApiData = null;
      isSurahDetailsLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      var selectedTranslatorId =
          translatorId ?? prefs.getString('selectedTranslatorId') ?? '1';
      print(
        'Loading offline surah details for Surah $surahNumber with translator ID $selectedTranslatorId',
      );

      //folder path
      // Only English is supported offline; other languages handled by API
      String folderPath = 'assets/quran/en/s00';
      update();

      // Load local JSON file
      final String response = await rootBundle.loadString(
        '$folderPath$surahNumber.json',
      );
      final data = json.decode(response);
      if (data is List) {
        suraDetailsApiData = SuraDetaileModel.fromJson(data.first);
      } else if (data is Map<String, dynamic>) {
        suraDetailsApiData = SuraDetaileModel.fromJson(data);
      } else {
        throw Exception('Unexpected JSON format');
      }
    } catch (e) {
      print('Error loading surah details: $e');
    } finally {
      isSurahDetailsLoading.value = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(); // notify listeners after frame build
      });
    }
  }

  // change surah detail ayah font size

  int? lastSurahNumber;

  void changeSurah(int surahNumber) {
    lastSurahNumber = surahNumber;
    loadSurahDetails(surahNumber: surahNumber);
    update(); // refresh the GetBuilder UI

    // Navigate after updating state (prevents setState/build conflicts)
    Future.microtask(() {
      Get.to(
        () => OfflineSuraDetaileScreen(
          appBackButton: true,
          surahNumber: surahNumber.toString(),
        ),
        arguments: 0,
      );
    });
  }

  // juzz data
  RxBool isJuzzLoading = true.obs;
  JuzListModel? juzListApiData;
  Future<void> loadJuzzList() async {
    print('Loading offline juzz list...');
    try {
      final String response = await rootBundle.loadString(
        'assets/quran/juzz_list.json',
      );
      final data = json.decode(response);
      juzListApiData = JuzListModel.fromJson(data);
    } catch (e) {
      print('Error loading juzz list: $e');
    } finally {
      isJuzzLoading.value = false;
    }
  }

  final verses = <Map<String, dynamic>>[].obs; // cached verses
  final results = <Map<String, dynamic>>[].obs; // search results
  final isQuranSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    initLoader();
  }

  Future<void> initLoader() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isQuranSearching.value = true;
    });
    await QuranLoader.instance.loadAllVerses();
    verses.assignAll(QuranLoader.instance.allVerses);
    isQuranSearching.value = false;
  }

  /// Search query on cached verses. Case-insensitive, supports Arabic or translation.
  void search(String q) {
    final query = removeDiacritics(q.trim().toLowerCase());
    print('search data =====> $query');

    if (query.isEmpty) {
      results.clear();
      return;
    }

    final filtered = verses.where((v) {
      final arabic = removeDiacritics((v['arabic_name'] ?? '').toString());
      final noTashkeel = removeDiacritics(
        (v['text_without_taskeel'] ?? '').toString(),
      );
      final translated = removeDiacritics(
        (v['translated_name'] ?? '').toString(),
      );
      final chapterName = removeDiacritics(
        ((v['chapter'] ?? {})['arabic_name'] ?? '').toString(),
      );

      return arabic.contains(query) ||
          noTashkeel.contains(query) ||
          translated.contains(query) ||
          chapterName.contains(query);
    }).toList();

    results.assignAll(filtered);
    print('Search found: ${filtered.length} results');
  }

  void clearSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isQuranSearching.value = false;

      results.clear();
      update();
    });
  }

  String removeDiacritics(String input) {
    // Step 1: Normalize presentation forms (Arabic special letters)
    const arabicMap = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ٱ': 'ا',
      'ء': '',
      'ؤ': 'و',
      'ئ': 'ي',
      'ة': 'ه',
      'ى': 'ي',
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    // Step 2: Replace each special char
    String normalized = input;
    arabicMap.forEach((key, value) {
      normalized = normalized.replaceAll(key, value);
    });

    // Step 3: Remove tashkeel / diacritics
    final diacriticsRegex = RegExp(
      r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]',
    );
    normalized = normalized.replaceAll(diacriticsRegex, '');

    // Step 4: Trim and lowercase for safety
    return normalized.trim().toLowerCase();
  }
}
