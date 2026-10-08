// dhikr_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/model/response/dua_details_model.dart';
import 'package:nazar_e_alam/data/model/response/dua_list_model.dart';
import 'package:nazar_e_alam/data/model/response/local_dua_model.dart';
import 'package:nazar_e_alam/data/repository/dua_list_repo.dart';

class DuaController extends GetxController implements GetxService {
  final DuaRepo duaRepo;
  DuaController({required this.duaRepo});
  var duaList = <LocalDuaModel>[].obs;
  String? duaId;

  @override
  void onInit() {
    // fetchDuaListData();

    super.onInit();
  }

// local variable
  RxBool isDuaListLoading = false.obs;
  DuaListModel? duaApiData;

// get dua list form here
  Future<void> fetchDuaListData({String? translatorId}) async {
    try {
      isDuaListLoading(true);

      final response = await duaRepo.getDuaListRepo();

      if (response.statusCode == 200) {
        duaApiData = DuaListModel.fromJson(response.body);
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
  RxBool isDuaDetailsLoading = false.obs;
  DuaDetailsModel? duaDetailApiData;

// get dua details function
  Future<void> fetchDuaDetailsData({String? duaId}) async {
    try {
      isDuaDetailsLoading(true);

      final response = await duaRepo.getDuaDetailsRepo(duaId.toString());

      if (response.statusCode == 200) {
        duaDetailApiData = DuaDetailsModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isDuaDetailsLoading(false);
      update();
    }
  }

  void deleteDua(String duaId) {
    duaList.removeWhere((dua) => dua.id == duaId);
    LocalDuaStorage.saveDuaList(duaList);
  }

  void addDua(
    String englishName,
    String arabicName,
    String englishDescription,
    String arabicDescription,
  ) {
    final duaId = DateTime.now().millisecondsSinceEpoch.toString();
    duaList.add(LocalDuaModel(
      id: duaId,
      englishName: englishName,
      arabicName: arabicName,
      englishDescription: englishDescription,
      arabicDescription: arabicDescription,
    ));

    LocalDuaStorage.saveDuaList(duaList);
  }

  void loadDuaList() {
    LocalDuaStorage.loadDuaList().then((savedList) {
      duaList.assignAll(savedList);
    });
  }
}

class LocalDuaStorage {
  static const duaListKey = 'dua_list';

  static Future<void> deleteDuaCount(String duaId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(duaId);
  }

  static Future<void> saveDuaList(List<LocalDuaModel> duaList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(duaList.map((dua) => dua.toJson()).toList());
    prefs.setString(duaListKey, jsonString);
  }

  static Future<List<LocalDuaModel>> loadDuaList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(duaListKey);
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => LocalDuaModel.fromJson(item)).toList();
    } else {
      return [];
    }
  }
}
