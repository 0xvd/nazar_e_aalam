// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/category/category_screen.dart';

class ModernQuickActions extends StatelessWidget {
  const ModernQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickAction(
        Images.ModernIcon_ReadQuran,
        'quran'.tr,
        RouteHelper.suraList,
      ),
      _QuickAction(
        Images.ModernIcon_AudioQuran,
        'audio_quran'.tr,
        RouteHelper.recters,
      ),
      _QuickAction(Images.ModernIcon_Duas, 'dua'.tr, RouteHelper.dua),
      _QuickAction(Images.ModernIcon_Dhikr, 'dikir'.tr, RouteHelper.dhikr),
      _QuickAction(
        Images.ModernIcon_QiblaKaaba,
        'compass'.tr,
        RouteHelper.compass,
        tint: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
        border: Border.all(
          color: Get.isDarkMode
              ? AppColorModern.emerald.withOpacity(0.05)
              : Colors.white.withOpacity(0.05),
        ),
        boxShadow: Get.isDarkMode
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'quick_actions'.tr,
                style: robotoMedium.copyWith(
                  color: Get.isDarkMode
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColorModern.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => CategoryScreen(appBackButton: true)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'view_all'.tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_SMALL,
                        color: AppColorModern.emerald,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColorModern.emerald,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
              itemBuilder: (context, index) {
                final item = items[index];
                return _QuickActionTile(
                  icon: item.icon,
                  label: item.label,
                  route: item.route,
                  tint: item.tint,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String icon;
  final String label;
  final String route;
  final bool tint;
  _QuickAction(this.icon, this.label, this.route, {this.tint = true});
}

class _QuickActionTile extends StatelessWidget {
  final String icon;
  final String label;
  final String route;
  final bool tint;
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
      onTap: () => Get.toNamed(route),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.grey.withValues(alpha: 0.05)
                    : AppColorModern.emerald.withOpacity(0.07),
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
                border: Border.all(color: AppColorModern.emerald, width: 0.08),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      icon,
                      color: tint ? AppColorModern.emerald : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
