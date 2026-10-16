// helpers/time_adjustment_helper.dart
import 'package:get/get.dart';
import '../controller/prayer_time_adjustment.dart';

class TimeAdjustmentHelper {
  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String getDisplayTime({
    required String prayerKey,
    required String defaultTime,
  }) {
    final controller = Get.find<PrayerTimeAdjustmentController>();
    return controller.getAdjustedTimeString(prayerKey, defaultTime);
  }

  String getAdjustmentText(String prayerKey) {
    final controller = Get.find<PrayerTimeAdjustmentController>();
    return controller.getAdjustmentString(prayerKey) ?? '';
  }

  bool isTimeAdjusted(String prayerKey) {
    final controller = Get.find<PrayerTimeAdjustmentController>();
    return controller.isAdjusted(prayerKey);
  }

  DateTime getAdjustedDateTime({
    required String prayerKey,
    required String defaultTime,
  }) {
    try {
      final parts = defaultTime.split(':');
      final baseTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final controller = Get.find<PrayerTimeAdjustmentController>();
      return controller.getAdjustedTime(prayerKey, baseTime);
    } catch (e) {
      return DateTime.now();
    }
  }
}
