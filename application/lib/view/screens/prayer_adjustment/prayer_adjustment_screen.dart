// screens/prayer_adjustment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/model/response/prayer_item.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import '../../../controller/package_prayer_time_controller.dart';
import '../../../controller/prayer_time_adjustment.dart';
import '../../../util/dimensions.dart';
import 'widget/time_selector_screen.dart';

class PrayerAdjustmentScreen extends StatelessWidget {
  PrayerAdjustmentScreen({super.key, required this.appBackButton});

  final bool appBackButton;

  final PrayerTimeAdjustmentController _adjustmentController = Get.put(
    PrayerTimeAdjustmentController(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _initController(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: "adjust_prayer_time".tr,
            isBackButtonExist: appBackButton,
          ),
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.05),
                      theme.scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: GetBuilder<PrayerTimeController>(
                  builder: (autoController) {
                    final data = autoController.prayerTimeModel?.data;
                    if (data == null) return const SizedBox();

                    // Build prayer items list
                    final prayerItems = _buildPrayerItems(data);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title - Daily Prayers
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                          ),
                          child: Text(
                            'prayer_times'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 18,
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Daily Prayer Cards
                        ...prayerItems
                            .where(
                              (item) => [
                                'fajr',
                                'zuhr',
                                'asr',
                                'maghrib',
                                'isha',
                              ].contains(item.key),
                            )
                            .map(
                              (item) => _buildPrayerCard(context, theme, item),
                            ),

                        const SizedBox(height: 24),

                        // Section Title - Ramadan Times
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                          ),
                          child: Text(
                            'ramadan_times'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 18,
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Ramadan Prayer Cards
                        ...prayerItems
                            .where(
                              (item) => ['sehri', 'iftar'].contains(item.key),
                            )
                            .map(
                              (item) => _buildPrayerCard(context, theme, item),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build prayer items from API data
  List<PrayerItem> _buildPrayerItems(dynamic data) {
    return [
      PrayerItem(
        key: 'fajr',
        name: 'fajr'.tr,
        defaultTime: data.fajrStart ?? '00:00',
        icon: Images.Icon_Fajr,
        gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      ),
      PrayerItem(
        key: 'zuhr',
        name: data.isJumma == true ? 'jumuah'.tr : 'dhuhr'.tr,
        defaultTime: data.zuhrStart ?? '00:00',
        icon: Images.Icon_Dhuhr,
        gradient: [const Color(0xFFf093fb), const Color(0xFFF5576C)],
      ),
      PrayerItem(
        key: 'asr',
        name: 'asr'.tr,
        defaultTime: data.asrStart ?? '00:00',
        icon: Images.Icon_Asr,
        gradient: [const Color(0xFFfa709a), const Color(0xFFfee140)],
      ),
      PrayerItem(
        key: 'maghrib',
        name: 'magrib'.tr,
        defaultTime: data.maghribStart ?? '00:00',
        icon: Images.Icon_Maghrib,
        gradient: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      ),
      PrayerItem(
        key: 'isha',
        name: 'isha'.tr,
        defaultTime: data.ishaStart ?? '00:00',
        icon: Images.Icon_Isha,
        gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      ),
      PrayerItem(
        key: 'sehri',
        name: 'Sehri'.tr,
        defaultTime: data.sehriEnd ?? '00:00',
        icon: Images.sehri,
        gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      ),
      PrayerItem(
        key: 'iftar',
        name: 'Iftar'.tr,
        defaultTime: data.iftarStart ?? '00:00',
        icon: Images.ifter,
        gradient: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      ),
    ];
  }

  // Build individual prayer card
  Widget _buildPrayerCard(
    BuildContext context,
    ThemeData theme,
    PrayerItem prayer,
  ) {
    return Obx(() {
      final isAdjusted = _adjustmentController.isAdjusted(prayer.key);
      final adjustmentString = _adjustmentController.getAdjustmentString(
        prayer.key,
      );

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          vertical: 5,
        ),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => _showTimeAdjustmentDialog(context, prayer),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isAdjusted
                      ? theme.primaryColor.withValues(alpha: 0.3)
                      : theme.dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAdjusted
                        ? theme.primaryColor.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAdjusted
                              ? prayer.gradient
                              : [
                                  theme.hintColor.withValues(alpha: 0.2),
                                  theme.hintColor.withValues(alpha: 0.1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 35,
                          height: 35,
                          child: SvgPicture.asset(
                            prayer.icon,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              isAdjusted
                                  ? Colors.white
                                  : theme.hintColor.withValues(alpha: 0.5),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prayer.name.tr,
                            style: robotoBold.copyWith(
                              fontSize: 17,
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (isAdjusted && adjustmentString != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 14,
                                        color: theme.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        translateText(adjustmentString),
                                        style: robotoMedium.copyWith(
                                          fontSize: 13,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  "not_adjusted".tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: 13,
                                    color: theme.hintColor,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow with animation hint
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAdjusted
                            ? theme.primaryColor.withValues(alpha: 0.1)
                            : theme.hintColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 24,
                        color: isAdjusted
                            ? theme.primaryColor
                            : theme.hintColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // Initialize controller
  Future<PrayerTimeAdjustmentController> _initController() async {
    await _adjustmentController.init();
    return _adjustmentController;
  }

  // Show time adjustment dialog
  void _showTimeAdjustmentDialog(BuildContext context, PrayerItem prayer) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return TimeSelectorScreen(
          prayerKey: prayer.key,
          prayerName: prayer.name,
          defaultTime: prayer.defaultTime,
          onSave: (key, minutes) async {
            await _adjustmentController.updateAdjustment(key, minutes);
            Get.back();
          },
          onCancel: () {
            Get.back();
          },
        );
      },
    );
  }
}
