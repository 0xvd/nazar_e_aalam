// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/helper/date_converter.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';

import '../../../../../util/images.dart';
import '../../../../../util/styles.dart';

/// Classic next-prayer banner: a rounded brand card with the next prayer,
/// its time, today's English + Hijri date and the banner illustration.
class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    final gradient = dark
        ? const [Color(0xFF3A2414), Color(0xFF241A12)]
        : [primary, Color.lerp(primary, const Color(0xFFE8202A), 0.30)!];

    final prayer = Get.find<PrayerTimeController>();

    return Obx(() {
      final is24HourFormat = prayer.is24HourFormat.value;
      final waqtName = prayer.currentWaqtName.value;
      final waqtTime = translateText(
        DateConverter.formatPrayerTime(
          prayer.currentWaktTime.value,
          is24HourFormat,
        ),
      );

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: dark ? Border.all(color: primary.withOpacity(0.35)) : null,
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(dark ? 0.15 : 0.30),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'next_prayer'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          waqtName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      Text(
                        waqtTime,
                        style: robotoBold.copyWith(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          Images.Icon_Calender,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translateText(
                                  DateFormat.yMMMEd().format(DateTime.now()),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoMedium.copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                translateText(
                                  HijriCalendar.fromDate(
                                    DateTime.now(),
                                  ).toFormat('dd MMMM yyyy'),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              Images.NewBanner_Image,
              height: 120,
              width: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const SizedBox(height: 120, width: 120),
            ),
          ],
        ),
      );
    });
  }
}