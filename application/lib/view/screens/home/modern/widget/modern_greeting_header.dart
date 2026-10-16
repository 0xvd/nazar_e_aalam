// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ModernGreetingHeader extends StatelessWidget {
  final dynamic mosqueData;
  const ModernGreetingHeader({super.key, required this.mosqueData});

  static const _textDark = Color(0xFF1E2B22);
  static const _textMuted = Color(0xFF5B6B5E);

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimeController = Get.find<PrayerTimeController>();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
        bottomRight: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(
                  Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0,
                  1.0,
                ),
              child: Image.asset(
                Images.ModernIllustration_MosqueHeader,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Platform.isIOS ? 60 : 40,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: _textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (mosqueData?.mosqueName ?? 'Zabi').toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.FONT_SIZE_OVER_LARGE + 4,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildActions(context),
                  ],
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Text(
                  'may_allah_bless_you'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.FONT_SIZE_SMALL,
                    color: AppColorModern.textSecondary,
                  ),
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: _textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        prayerTimeController.saveLocalStoreCity ??
                            prayerTimeController.currentAddress.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT,
                          color: _textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 35),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(
          icon: Get.isDarkMode
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          tooltip: 'light_or_dark_mode'.tr,
          onTap: () => Get.find<ThemeController>().toggleTheme(),
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          svgIcon: Images.ModernIcon_Notification,
          tooltip: 'settings'.tr,
          onTap: () => Get.toNamed(RouteHelper.settings),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String? svgIcon;
  final IconData? icon;
  final String tooltip;
  final VoidCallback onTap;
  const _HeaderIconButton({
    this.svgIcon,
    this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: svgIcon != null
              ? SvgPicture.asset(svgIcon!, height: 18, width: 18)
              : Icon(icon, size: 18, color: AppColorModern.emerald),
        ),
      ),
    );
  }
}
