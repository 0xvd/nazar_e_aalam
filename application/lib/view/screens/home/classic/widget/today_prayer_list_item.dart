// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class TodaysprayerWidget extends StatelessWidget {
  final String iconImage;
  final String prayerName;
  final String adhan;
  final String jamah;
  final bool? isSunrise;
  final String? sunriseStart;
  final bool? isPrayerpackage;
  final bool isAdjusted; // NEW
  final String adjustmentText; // NEW

  const TodaysprayerWidget({
    super.key,
    required this.iconImage,
    required this.prayerName,
    required this.adhan,
    required this.jamah,
    this.isSunrise,
    this.sunriseStart,
    this.isPrayerpackage,
    this.isAdjusted = false, // NEW
    this.adjustmentText = '', // NEW
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isAdjusted
              ? Dimensions.PADDING_SIZE_SMALL
              : Dimensions.PADDING_SIZE_DEFAULT,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),

          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                // Item icon
                Row(
                  children: [
                    SvgPicture.asset(
                      iconImage,
                      height: 24,
                      fit: BoxFit.fill,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    // Prayer name
                    Text(
                      prayerName,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Time and adjustment indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSunrise == true ? sunriseStart! : adhan,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(),
                    ),
                    // Adjustment badge
                    if (isAdjusted && adjustmentText.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          translateText(adjustmentText),
                          style: robotoRegular.copyWith(
                            fontSize: 9,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
