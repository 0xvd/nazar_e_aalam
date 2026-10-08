// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ModernQuranCtaBanner extends StatelessWidget {
  const ModernQuranCtaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Images.ModernIllustration_QuranNight,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.15),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'quran_cta_title'.tr,
                  style: robotoMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 200,
                  child: Text(
                    'quran_cta_subtitle'.tr,
                    style: robotoRegular.copyWith(
                      color: AppColorModern.primaryGreen,
                      fontSize: Dimensions.FONT_SIZE_SMALL,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
                ElevatedButton(
                  onPressed: () => Get.toNamed(RouteHelper.suraList),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorModern.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_LARGE + 10,
                    ),
                  ),
                  child: Text('start_reading'.tr, style: robotoRegular),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
