// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/util/styles.dart';

/// One prayer tile for the classic home grid. Must stay a direct child of a
/// Row (it returns an Expanded). Constructor is unchanged.
class TodaysprayerWidget extends StatelessWidget {
  final String iconImage;
  final String prayerName;
  final String adhan;
  final String jamah;
  final bool? isSunrise;
  final String? sunriseStart;
  final bool? isPrayerpackage;
  final bool isAdjusted;
  final String adjustmentText;

  const TodaysprayerWidget({
    super.key,
    required this.iconImage,
    required this.prayerName,
    required this.adhan,
    required this.jamah,
    this.isSunrise,
    this.sunriseStart,
    this.isPrayerpackage,
    this.isAdjusted = false,
    this.adjustmentText = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final border = dark ? const Color(0xFF3A2E24) : const Color(0xFFF0E4D3);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.35 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(dark ? 0.20 : 0.12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconImage,
                  height: 22,
                  width: 22,
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prayerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(fontSize: 13, color: primary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isSunrise == true ? (sunriseStart ?? adhan) : adhan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (isAdjusted && adjustmentText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        translateText(adjustmentText),
                        style: robotoRegular.copyWith(
                          fontSize: 9,
                          color: primary,
                          fontWeight: FontWeight.w600,
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