// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_milestone_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ModernQuranMilestoneCard extends StatelessWidget {
  const ModernQuranMilestoneCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    final trackColor = primary.withOpacity(dark ? 0.22 : 0.14);

    return GetX<QuranMilestoneController>(
      builder: (controller) {
        final read = controller.pagesReadToday.value;
        final goal = controller.dailyGoal.value;
        final ratio = controller.progressRatio.clamp(0.0, 1.0);
        final remaining = (goal - read).clamp(0, goal);

        return GestureDetector(
          onTap: () => Get.toNamed(RouteHelper.suraList),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primary.withOpacity(0.15)),
              boxShadow: dark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              children: [
                _CircularProgress(
                  ratio: ratio,
                  read: read,
                  goal: goal,
                  primary: primary,
                  track: trackColor,
                  textColor: textColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'quran_milestone_title'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'quran_milestone_subtitle'.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 8,
                                backgroundColor: trackColor,
                                valueColor: AlwaysStoppedAnimation(primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(ratio * 100).toStringAsFixed(0)}%',
                            style: robotoMedium.copyWith(
                              fontSize: 12,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        title: remaining == 0
                            ? 'quran_milestone_complete'.tr
                            : '$remaining ${'quran_milestone_remaining'.tr}',
                        subtitle: 'quran_milestone_subtitles'.tr,
                        primary: primary,
                        textColor: textColor,
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
  final Color primary;
  final Color track;
  final Color? textColor;
  const _CircularProgress({
    required this.ratio,
    required this.read,
    required this.goal,
    required this.primary,
    required this.track,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: track,
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                Images.Icon_Quran,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$read',
                    style: robotoBold.copyWith(fontSize: 20, color: textColor),
                  ),
                  Text(
                    '/$goal',
                    style: robotoRegular.copyWith(
                      fontSize: 10,
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
  final Color primary;
  final Color? textColor;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 18, color: primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: robotoMedium.copyWith(fontSize: 11, color: textColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: robotoRegular.copyWith(
                      fontSize: 10,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: primary, size: 20),
          ],
        ),
      ),
    );
  }
}