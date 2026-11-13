// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/view/base/feature_grid.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_greeting_header.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_next_prayer_card.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_quran_milestone_card.dart';

/// Modern home: greeting header, floating next-prayer card, Quran milestone,
/// then every feature as grouped cards. Content scrolls behind the floating
/// glass nav bar, so the bottom has extra padding.
class ModernHomeScreen extends StatelessWidget {
  const ModernHomeScreen({super.key});

  // Clears the floating glass nav bar (bar 68 + margin + safe area).
  static const double _navClearance = 110;

  @override
  Widget build(BuildContext context) {
    final hasInternet = Get.find<InternetController>().hasInternet.value;
    return GetBuilder<SettingsController>(
      builder: (settingsController) {
        return GetBuilder<PrayerTimeController>(
          builder: (prayerTimeController) {
            final isLoading = _isLoadingState(
              settingsController,
              prayerTimeController,
            );
            final mosqueData = settingsController.mosqueSettingsApiData?.data;
            final dark = Theme.of(context).brightness == Brightness.dark;

            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: dark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : AppColorModern.scaffoldBackground,
              body: isLoading || (mosqueData == null && !hasInternet)
                  ? const SafeArea(child: DashbordShimmerScreen())
                  : _buildBody(context, mosqueData, prayerTimeController),
            );
          },
        );
      },
    );
  }

  bool _isLoadingState(
    SettingsController settingsController,
    PrayerTimeController prayerTimeController,
  ) {
    return settingsController.isMosqueSettingsLoading.value ||
        prayerTimeController.isprayerTimeLoading.value ||
        settingsController.mosqueSettingsApiData == null;
  }

  Widget _buildBody(
    BuildContext context,
    dynamic mosqueData,
    PrayerTimeController prayerTimeController,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModernGreetingHeader(mosqueData: mosqueData),
          Transform.translate(
            offset: Offset.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.PADDING_SIZE_DEFAULT,
                16,
                Dimensions.PADDING_SIZE_DEFAULT,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModernNextPrayerCard(
                    prayerTimeController: prayerTimeController,
                  ),
                  const SizedBox(height: 10),
                  const ModernQuranMilestoneCard(),
                  const SizedBox(height: 10),
                  const FeatureGrid(
                    modern: true,
                    padding: EdgeInsets.zero,
                    // spacing: 10,
                  ),
                  const SizedBox(height: _navClearance),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}