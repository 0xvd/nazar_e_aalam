import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_adjustment.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/helper/salat_waqt_service.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/view/screens/home/classic/classic_home_screen.dart';
import 'package:nazar_e_alam/view/screens/home/modern/modern_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    Get.find<InternetController>().checkConnection();
    Get.find<SettingsController>().fetchMosqueSettingsData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prayerTimeController = Get.find<PrayerTimeController>();

      // 1. Get location first
      await prayerTimeController.getLocation();

      // 2. Load settings
      prayerTimeController.loadSwitchValue();
      prayerTimeController.loadPrayerTimeSettings();
      Get.find<SettingsController>().fetchMosqueSettingsData();

      // 3. Fetch prayer time
      await _fetchPrayerTimes(prayerTimeController);

      // 4. Init adjustment
      Get.find<PrayerTimeAdjustmentController>().init();
      SalatWaqtService.initializeSalatWaqt();
    });
  }

  Future<void> _fetchPrayerTimes(
    PrayerTimeController prayerTimeController,
  ) async {
    final prefs = Get.find<SharedPreferences>();

    final isPrayerTme = prefs.getBool(AppConstants.isPrayerTme);
    final saveCityName = prefs.getString(AppConstants.saveCityName);

    await prayerTimeController.fetchPrayerTime(
      isManualPrayerTme: isPrayerTme ?? false,
      manualCity:
          saveCityName ?? prayerTimeController.currentAddress.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layout = Get.find<HomeLayoutController>().currentLayout.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
        child: layout == HomeLayoutController.classic
            ? const ClassicHomeScreen(key: ValueKey('classic'))
            : ModernHomeScreen(key: ValueKey('modern')),
      );
    });
  }
}