// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class _FeatureItem {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color titleColor;
  final String asset;
  final bool isSvg;
  final double illustrationSize;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.titleColor,
    required this.asset,
    required this.onTap,
    this.isSvg = false,
    this.illustrationSize = 30,
  });
}

class IslamicFeatureGrid extends StatelessWidget {
  const IslamicFeatureGrid({super.key});

  static const double _gap = 5;
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      _FeatureItem(
        title: 'daily_adhkar_title'.tr,
        subtitle: 'daily_adhkar_subtitle'.tr,
        backgroundColor: isDark
            ? const Color.fromARGB(255, 69, 76, 70)
            : const Color(0xFFDCE9DD),
        titleColor: const Color(0xFF223126),
        asset: Images.ModernIllustration_AdhkarScene,
        illustrationSize: 50,
        onTap: () => Get.toNamed(RouteHelper.dhikr),
      ),
      _FeatureItem(
        title: 'hadith_of_the_day_title'.tr,
        subtitle: 'hadith_of_the_day_subtitle'.tr,
        backgroundColor: isDark
            ? const Color.fromARGB(255, 99, 94, 82)
            : const Color(0xFFF8F1DF),
        titleColor: const Color(0xFF2B2A22),
        asset: Images.ModernIllustration_HadithOfDay,
        onTap: () => Get.toNamed(RouteHelper.hadithBookName),
      ),
      _FeatureItem(
        title: 'masjid_nearby_title'.tr,
        subtitle: 'masjid_nearby_subtitle'.tr,
        backgroundColor: isDark
            ? const Color.fromARGB(255, 97, 83, 83)
            : const Color(0xFFF3F3F3),
        titleColor: const Color(0xFF232323),
        asset: Images.ModernIllustration_MasjidNearby,
        onTap: () => Get.toNamed(RouteHelper.nearByMosque),
      ),
      _FeatureItem(
        title: 'zakat_calculator_title'.tr,
        subtitle: 'zakat_calculator_subtitle'.tr,
        backgroundColor: isDark
            ? const Color.fromARGB(255, 85, 78, 78)
            : const Color(0xFFEFEFEF),
        titleColor: const Color(0xFF232323),
        asset: Images.ModernIllustration_Calendar,
        isSvg: true,
        onTap: () => Get.toNamed(RouteHelper.zakatCalculator),
      ),
      _FeatureItem(
        title: 'qibla_direction_title'.tr,
        subtitle: 'qibla_direction_subtitle'.tr,
        backgroundColor: isDark
            ? const Color.fromARGB(255, 69, 81, 79)
            : const Color(0xFFDCEEEC),
        titleColor: const Color(0xFF1B2E2C),
        asset: Images.ModernIllustration_Compass,
        onTap: () => Get.toNamed(RouteHelper.compass),
      ),
    ];

    return SizedBox(
      height: 168,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 32,
            child: _FeatureCard(item: items[0], radius: _radius),
          ),
          const SizedBox(width: _gap),

          Expanded(
            flex: 34,
            child: Column(
              children: [
                Expanded(
                  child: _FeatureCard(item: items[1], radius: _radius),
                ),
                const SizedBox(height: _gap),
                Expanded(
                  child: _FeatureCard(item: items[2], radius: _radius),
                ),
              ],
            ),
          ),
          const SizedBox(width: _gap),

          Expanded(
            flex: 34,
            child: Column(
              children: [
                Expanded(
                  child: _FeatureCard(item: items[3], radius: _radius),
                ),
                const SizedBox(height: _gap),
                Expanded(
                  child: _FeatureCard(item: items[4], radius: _radius),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  final double radius;

  const _FeatureCard({required this.item, required this.radius});

  static const double _illustrationInset = 6;

  static const double _titleHeight = 18;
  static const double _subtitleHeight = 30;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: item.backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.onTap,
        child: Stack(
          children: [
            Positioned(
              right: _illustrationInset,
              bottom: _illustrationInset,
              child: _CardIllustration(
                asset: item.asset,
                isSvg: item.isSvg,
                size: item.illustrationSize,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: _titleHeight,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_SMALL,

                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : item.titleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: _subtitleHeight,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : item.titleColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardIllustration extends StatelessWidget {
  final String asset;
  final bool isSvg;
  final double size;

  const _CardIllustration({
    required this.asset,
    required this.isSvg,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: isSvg
          ? SvgPicture.asset(asset, width: size, height: size)
          : Image.asset(asset, width: size, height: size),
    );
  }
}
