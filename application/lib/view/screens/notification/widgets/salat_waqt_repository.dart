import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/view/screens/notification/widgets/salat_waqt.dart';

class SalatWaqtRepository {
  static const String _salatWaqtKey = "salat_waqt";

  Future<List<SalatWaqt>> getSalatWaqtList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_salatWaqtKey);

    if (jsonString == null) return [];

    final List<dynamic> decodedList = jsonDecode(jsonString);
    final list = decodedList.map((item) => SalatWaqt.fromJson(item)).toList();
    list.sort((a, b) => a.id.compareTo(b.id));

    return list;
  }

  Future<SalatWaqt?> getSalatWaqtById(int id) async {
    final list = await getSalatWaqtList();
    return list.firstWhereOrNull((element) => element.id == id);
  }

  Future<void> saveSalatWaqt(SalatWaqt salatWaqt) async {
    final list = await getSalatWaqtList();
    final existing = list.firstWhereOrNull(
      (element) => element.id == salatWaqt.id,
    );

    if (existing != null) list.remove(existing);

    list.add(salatWaqt);
    final jsonString = jsonEncode(list);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_salatWaqtKey, jsonString);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_salatWaqtKey);
  }

  Future<void> seedSalatWaqt() async {
    final list = _defaultSalatWaqtList();
    final jsonString = jsonEncode(list);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_salatWaqtKey, jsonString);
  }

  List<SalatWaqt> _defaultSalatWaqtList() {
    final now = DateTime.now();
    return [
      SalatWaqt(id: 1, name: "Fajr", time: now, isNotificationEnabled: true),
      SalatWaqt(id: 2, name: "Dhuhr", time: now, isNotificationEnabled: true),
      SalatWaqt(id: 3, name: "Asr", time: now, isNotificationEnabled: true),
      SalatWaqt(id: 4, name: "Magrib", time: now, isNotificationEnabled: true),
      SalatWaqt(id: 5, name: "Isha", time: now, isNotificationEnabled: true),
    ];
  }
}
