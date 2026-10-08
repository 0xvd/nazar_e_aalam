// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_milestone_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ModernQuranMilestoneCard extends StatelessWidget {
  const ModernQuranMilestoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<QuranMilestoneController>(
      builder: (controller) {
        final read = controller.pagesReadToday.value;
        final goal = controller.dailyGoal.value;
        final ratio = controller.progressRatio;
        final remaining = (goal - read).clamp(0, goal);
        final isDarkmode = Get.isDarkMode;

        return GestureDetector(
          onTap: () => Get.toNamed(RouteHelper.suraList),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(
                Dimensions.RADIUS_EXTRA_LARGE,
              ),
              boxShadow: isDarkmode
                  ? null
                  : [
                      BoxShadow(
                        color: Get.isDarkMode
                            ? Colors.black.withOpacity(0.25)
                            : Colors.grey.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              children: [
                _CircularProgress(ratio: ratio, read: read, goal: goal),
                const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'quran_milestone_title'.tr,
                        style: robotoBold.copyWith(),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'quran_milestone_subtitle'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL - 2,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: ratio.clamp(0.0, 1.0),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(20),
                                backgroundColor: isDarkmode
                                    ? Colors.grey.withValues(alpha: 0.5)
                                    : AppColorModern.emeraldSoftBg,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColorModern.emerald,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(ratio * 100).toStringAsFixed(0)}%',
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL,
                                color: AppColorModern.emerald,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      _InfoRow(
                        title: remaining == 0
                            ? 'quran_milestone_complete'.tr
                            : '$remaining ${'quran_milestone_remaining'.tr}',
                        subtitle: 'quran_milestone_subtitles'.tr,
                        onTap: () => Get.toNamed(RouteHelper.suraList),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double ratio;
  final int read;
  final int goal;
  const _CircularProgress({
    required this.ratio,
    required this.read,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? Colors.grey.withValues(alpha: 0.05)
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    strokeWidth: 9,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Get.isDarkMode
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColorModern.emeraldSoftBg,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColorModern.emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Images.Icon_Quran,
                width: 24,
                height: 24,
                color: AppColorModern.emerald,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$read',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE + 5,

                      color: Get.isDarkMode
                          ? Colors.white
                          : AppColorModern.textPrimary,
                    ),
                  ),
                  Text(
                    '/$goal',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _InfoRow({required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : AppColorModern.chipGreenBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Text('📗', style: robotoMedium),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoMedium.copyWith(
                      color: Get.isDarkMode
                          ? Colors.white
                          : AppColorModern.textPrimary,
                      fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: robotoMedium.copyWith(
                      color: Get.isDarkMode
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColorModern.textSecondary,
                      fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Get.isDarkMode
                  ? Colors.white
                  : AppColorModern.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
