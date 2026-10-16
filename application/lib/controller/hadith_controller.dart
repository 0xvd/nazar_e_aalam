// ignore_for_file: avoid_print, strict_top_level_inference

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:nazar_e_alam/data/model/response/hadis_book_model.dart';
import 'package:nazar_e_alam/data/model/response/hadith_chapter_model.dart';
import 'package:nazar_e_alam/data/model/response/hadith_model.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class HadithController extends GetxController {
  // local variable
  RxBool isLoadingHadithChapter = false.obs;
  RxBool isLoadingHadith = false.obs;

  // hadith api key
  String hadithApiKey =
      "\$2y\$10\$IpN2jMeSLbrGxZ6zwEu3KAEr1ZmUjwQCYhRbiReqscXswndm";

  @override
  void onInit() {
    getHadishBookNameData();

    super.onInit();
  }

  HadisBookModel? hadisBookModel;
  HadithChapterModel? hadithChapterModel;
  HadithModel? hadithModel;

  // get hadith book list api call here
  getHadishBookNameData() async {
    isLoadingHadithChapter(true);
    try {
      const hadithApiKey =
          "\$2y\$10\$IpN2jMeSLbrGxZ6zwEu3KAEr1ZmUjwQCYhRbiReqscXswndm";
      final response = await http.get(
        Uri.parse(
          "${AppConstants.HADITH_BASE_URL}/api/books?apiKey=$hadithApiKey",
        ),
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        hadisBookModel = HadisBookModel.fromJson(data);
        update();
      }
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      isLoadingHadithChapter(false);
    }

    update();
  }

  // get hadith chaptar here
  getHadithBookChaptersData(arguments) async {
    isLoadingHadithChapter(true);
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConstants.HADITH_BASE_URL}/api/$arguments/chapters?apiKey=$hadithApiKey",
        ),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("RAW JSON: $data");  // <-- add this
        hadithChapterModel = HadithChapterModel.fromJson(data);
        update();
      }
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      isLoadingHadithChapter(false);
    }
  }

  // get hadith data here
  getAllHadithData(bookName, chapter) async {
    isLoadingHadith(true);
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConstants.HADITH_BASE_URL}/api/hadiths/?apiKey=$hadithApiKey&book=$bookName&chapter=$chapter&paginate=500",
        ),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("HADITH JSON: $data");   // <-- add this
        hadithModel = HadithModel.fromJson(data);
        update();
      } else {
        showCustomSnackBar("no_hadith_found_in_this_chapter".tr, isError: true);
      }
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      isLoadingHadith(false);
    }
  }
}
