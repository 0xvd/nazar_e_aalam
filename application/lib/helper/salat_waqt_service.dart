import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_adjustment.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/view/screens/notification/widgets/salat_waqt.dart';
import 'package:nazar_e_alam/view/screens/notification/widgets/salat_waqt_repository.dart';

import 'adhan_notification_service_helper.dart';

class SalatWaqtService {
  final SalatWaqtRepository _salatWaqtRepository;

  SalatWaqtService() : _salatWaqtRepository = SalatWaqtRepository();

  Future<DateTime?> getPrayerTimeByWaqt(SalatWaqt salatWaqt) async {
    return _getPrayerTime(salatWaqt);
  }

  Future<DateTime?> _getPrayerTime(SalatWaqt salatWaqt) async {
    final prefs = await SharedPreferences.getInstance();
    final isPrayerTme = prefs.getBool(AppConstants.isPrayerTme);
    final saveCityName = prefs.getString(AppConstants.saveCityName);

    await Get.find<PrayerTimeController>().fetchPrayerTime(
      reload: false,
      isManualPrayerTme: isPrayerTme ?? false,
      manualCity:
          saveCityName ??
          Get.find<PrayerTimeController>().currentAddress.toString(),
    );

    final autometicPrayerTime =
        Get.find<PrayerTimeController>().prayerTimeModel;

    if (autometicPrayerTime == null || autometicPrayerTime.data == null) {
      Get.log("Automatic prayer time data is null");
      return null;
    }

    // Get base prayer time from API
    DateTime baseTime;
    String prayerKey;
    Get.log(
      "Calculating time for ${salatWaqt.name} (ID: ${salatWaqt.id})\n ${autometicPrayerTime.data!.fajrStart}",
    );
    switch (salatWaqt.id) {
      case 1:
        baseTime = _parsePrayerTime(autometicPrayerTime.data!.fajrStart ?? "");
        prayerKey = 'fajr';
        break;
      case 2:
        baseTime = _parsePrayerTime(autometicPrayerTime.data!.zuhrStart ?? "");
        prayerKey = 'zuhr';
        break;
      case 3:
        baseTime = _parsePrayerTime(autometicPrayerTime.data!.asrStart ?? "");
        prayerKey = 'asr';
        break;
      case 4:
        baseTime = _parsePrayerTime(
          autometicPrayerTime.data!.maghribStart ?? "",
        );
        prayerKey = 'maghrib';
        break;
      case 5:
        baseTime = _parsePrayerTime(autometicPrayerTime.data!.ishaStart ?? "");
        prayerKey = 'isha';
        break;
      default:
        throw UnimplementedError("Invalid salatWaqt id: ${salatWaqt.id}");
    }

    // Apply user adjustments if any
    try {
      final adjustmentController = Get.find<PrayerTimeAdjustmentController>();
      final adjustedTime = adjustmentController.getAdjustedTime(
        prayerKey,
        baseTime,
      );
      Get.log(
        "Prayer: $prayerKey, Base: ${_formatTime(baseTime)}, Adjusted: ${_formatTime(adjustedTime)}",
      );
      return adjustedTime;
    } catch (e) {
      Get.log("Adjustment controller not found, using base time: $e");
      return baseTime;
    }
  }

  DateTime _parsePrayerTime(String time) {
    if (time.isEmpty) {
      throw const FormatException("Time string is empty");
    }

    final timeList = time.split(":");
    final hour = int.parse(timeList[0]);
    final min = int.parse(timeList[1]);
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
      min,
    );
  }

  // Helper method to format time for logging
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> updateSalatWaqt() async {
    final salatWaqtList = await _salatWaqtRepository.getSalatWaqtList();

    for (final element in salatWaqtList) {
      try {
        element.time = (await getPrayerTimeByWaqt(element)) ?? element.time;
        await _salatWaqtRepository.saveSalatWaqt(element);
      } catch (e) {
        Get.log("Failed to update SalatWaqt ${element.id}: $e");
      }
    }
  }

  static Future<void> checkNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  static Future<void> initializeSalatWaqt() async {
    checkNotificationPermission();
    final adhanNotificationServices = AdhanNotificationServiceImpl();
    await adhanNotificationServices.initializeNotification();

    final salatWaqtRepository = SalatWaqtRepository();
    var salatWaqtList = await salatWaqtRepository.getSalatWaqtList();

    if (salatWaqtList.isEmpty) {
      await salatWaqtRepository.seedSalatWaqt();
    }

    // Initialize the adjustment controller BEFORE updating salat waqt
    try {
      Get.find<PrayerTimeAdjustmentController>();
    } catch (e) {
      Get.put(PrayerTimeAdjustmentController());
      await Get.find<PrayerTimeAdjustmentController>().init();
    }

    final salatWaqtService = SalatWaqtService();
    await salatWaqtService.updateSalatWaqt();

    salatWaqtList = await salatWaqtRepository.getSalatWaqtList();
    for (final salatWaqt in salatWaqtList) {
      if (salatWaqt.isNotificationEnabled) {
        final time = salatWaqt.time.toLocal();
        Get.log(
          'Notification for ${salatWaqt.name}: ${time.toIso8601String().split('T')[0]} => ${time.toIso8601String().split('T')[1]}',
        );

        await adhanNotificationServices.scheduleNotification(
          id: salatWaqt.id,
          title: salatWaqt.name.toLowerCase().tr,
          body:
              '${'time_for'.tr} ${salatWaqt.name} ${'started_at'.tr} ${DateFormat.jm().format(time)}',
          dateTime: time,
          payload: time.toIso8601String(),
        );
      } else {
        await adhanNotificationServices.cancelNotification(salatWaqt.id);
      }
    }
  }
}
