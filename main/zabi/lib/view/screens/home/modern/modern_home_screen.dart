// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/ai_islamic_assistant/ai_islamic_assistant.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_greeting_header.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_info_cards.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_next_prayer_card.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_quick_actions.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_quran_cta_banner.dart';
import 'package:nazar_e_alam/view/screens/home/modern/widget/modern_quran_milestone_card.dart';

class ModernHomeScreen extends StatelessWidget {
  const ModernHomeScreen({super.key});
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

            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : AppColorModern.emeraldSoftBg,
              body: isLoading || (mosqueData == null && !hasInternet)
                  ? const SafeArea(child: DashbordShimmerScreen())
                  : _buildBody(context, mosqueData, prayerTimeController),
              floatingActionButton: _buildAiFab(context),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
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
            offset: const Offset(0, -25),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ModernNextPrayerCard(
                    prayerTimeController: prayerTimeController,
                  ),
                  const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                  const ModernQuranMilestoneCard(),
                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  ModernQuickActions(),
                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  // const ModernInfoCards(),
                  IslamicFeatureGrid(),
                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  const ModernQuranCtaBanner(),
                  const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT * 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiFab(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const AiIslamicAssistantScreen()),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  AppColorModern.emerald.withOpacity(0.35),
                  AppColorModern.emerald.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColorModern.emerald.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.cardColor,
                  ),
                  child: Image.asset(Images.aiAssistant, width: 30, height: 30),
                ),
                const SizedBox(width: 2),
                Text(
                  "${"ask_ai_key".tr} ",
                  style: robotoRegular.copyWith(
                    color: Get.isDarkMode
                        ? AppColor.cardColor
                        : AppColorModern.emeraldDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
