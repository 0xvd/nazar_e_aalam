// controllers/prayer_time_adjustment_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class PrayerTimeAdjustmentController extends GetxController {
  late SharedPreferences _prefs;

  // Store adjustments as Map<String, int> where key is prayer key and value is minutes
  final RxMap<String, int> _prayerAdjustments = <String, int>{}.obs;
  var isResetting = false.obs;
  var showCustomTimePicker = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeAdjustmentServices();
  }

  Future<void> initializeAdjustmentServices() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedAdjustments();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedAdjustments();
  }

  // Save adjustments to SharedPreferences
  Future<void> _saveAdjustments() async {
    final Map<String, dynamic> saveableMap = Map.fromEntries(
      _prayerAdjustments.entries.map(
        (entry) => MapEntry(entry.key, entry.value),
      ),
    );
    await _prefs.setString('prayerAdjustments', json.encode(saveableMap));
  }

  // Load saved adjustments from SharedPreferences
  void _loadSavedAdjustments() {
    final saved = _prefs.getString('prayerAdjustments');
    if (saved != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(saved);
        _prayerAdjustments.addAll(
          jsonMap.map((key, value) => MapEntry(key, value as int)),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error loading prayer adjustments: $e');
        }
        _prefs.remove('prayerAdjustments');
      }
    }
  }

  // Update adjustment for a specific prayer
  Future<void> updateAdjustment(String prayerKey, int adjustmentMinutes) async {
    if (adjustmentMinutes == 0) {
      _prayerAdjustments.remove(prayerKey);
    } else {
      _prayerAdjustments[prayerKey] = adjustmentMinutes;
    }
    await _saveAdjustments();
    update();
  }

  // Reset specific prayer or all prayers
  Future<void> resetPrayerTime({String? prayerKey}) async {
    try {
      isResetting(true);
      if (prayerKey != null) {
        _prayerAdjustments.remove(prayerKey);
      } else {
        _prayerAdjustments.clear();
      }
      await _saveAdjustments();
      update();
    } catch (e) {
      showCustomSnackBar('Failed to reset prayer times'.tr, isError: true);
    } finally {
      isResetting(false);
    }
  }

  // Get adjustment in minutes for a specific prayer
  int? getAdjustmentMinutes(String prayerKey) {
    return _prayerAdjustments[prayerKey];
  }

  // Get formatted adjustment string (e.g., "+5 min", "-10 min")
  String? getAdjustmentString(String prayerKey) {
    final minutes = _prayerAdjustments[prayerKey];
    if (minutes == null || minutes == 0) return null;
    return '${minutes > 0 ? '+' : ''}$minutes ${"min".tr}';
  }

  // Check if a prayer has been adjusted
  bool isAdjusted(String prayerKey) {
    return _prayerAdjustments.containsKey(prayerKey) &&
        _prayerAdjustments[prayerKey] != 0;
  }

  // Get adjusted time for a prayer
  DateTime getAdjustedTime(String prayerKey, DateTime defaultTime) {
    final adjustment = _prayerAdjustments[prayerKey] ?? 0;
    return defaultTime.add(Duration(minutes: adjustment));
  }

  // Get adjusted time string
  String getAdjustedTimeString(String prayerKey, String defaultTime) {
    try {
      final parts = defaultTime.split(':');
      final baseTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final adjustment = _prayerAdjustments[prayerKey] ?? 0;
      final adjustedTime = baseTime.add(Duration(minutes: adjustment));

      return '${adjustedTime.hour.toString().padLeft(2, '0')}:${adjustedTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return defaultTime;
    }
  }
}
