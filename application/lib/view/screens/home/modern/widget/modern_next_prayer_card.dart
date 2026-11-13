// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/helper/date_converter.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ModernNextPrayerCard extends StatefulWidget {
  final PrayerTimeController prayerTimeController;
  const ModernNextPrayerCard({super.key, required this.prayerTimeController});

  @override
  State<ModernNextPrayerCard> createState() => _ModernNextPrayerCardState();
}

class _ModernNextPrayerCardState extends State<ModernNextPrayerCard> {
  static const double _chipHeight = 108;

  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _recompute();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _recompute());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _recompute() {
    final timeStr = widget.prayerTimeController.currentWaktTime.value;
    try {
      final now = DateTime.now();
      var target = DateFormat('HH:mm').parse(timeStr);
      target = DateTime(
        now.year,
        now.month,
        now.day,
        target.hour,
        target.minute,
      );
      if (target.isBefore(now)) target = target.add(const Duration(days: 1));
      if (mounted) setState(() => _remaining = target.difference(now));
    } catch (_) {
      if (mounted) setState(() => _remaining = Duration.zero);
    }
  }

  String get _countdownText {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  int _activePrayerIndex(List<String?> times) {
    final now = DateTime.now();
    for (var i = 0; i < times.length; i++) {
      final t = times[i];
      if (t == null) continue;
      try {
        final parsed = DateFormat('HH:mm').parse(t);
        final today = DateTime(
          now.year,
          now.month,
          now.day,
          parsed.hour,
          parsed.minute,
        );
        if (today.isAfter(now)) return i;
      } catch (_) {
        continue;
      }
    }
    return 0;
  }

  _ChipStatus _chipStatus(int index, int activeIndex) {
    if (index < activeIndex) return _ChipStatus.passed;
    if (index == activeIndex) return _ChipStatus.active;
    return _ChipStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final controller = widget.prayerTimeController;
    final is24HourFormat = controller.is24HourFormat.value;
    final prayerData = controller.prayerTimeModel?.data;

    final times = [
      prayerData?.fajrStart,
      prayerData?.zuhrStart,
      prayerData?.asrStart,
      prayerData?.maghribStart,
      prayerData?.ishaStart,
    ];
    final activeIndex = _activePrayerIndex(times);

    final gradient = dark
        ? const [Color(0xFF4A2E18), Color(0xFF2B1D13)]
        : [primary, Color.lerp(primary, const Color(0xFFE8202A), 0.25)!];

    return Container(
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: dark
            ? Border.all(color: primary.withOpacity(0.35))
            : null,
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(dark ? 0.18 : 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            height: _chipHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'next_prayer'.tr,
                  style: robotoRegular.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.currentWaqtName.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    translateText(_countdownText),
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        translateText(
                          DateConverter.formatPrayerTime(
                            controller.currentWaktTime.value,
                            is24HourFormat,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoMedium.copyWith(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.volume_up_rounded,
                      size: 12,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 0.5,
            height: _chipHeight,
            color: Colors.white.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          Expanded(
            child: SizedBox(
              height: _chipHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _PrayerChip(
                    icon: Images.ModernPrayer_FajrSunrise,
                    name: 'fajr'.tr,
                    time: prayerData?.fajrStart ?? '00:00',
                    is24HourFormat: is24HourFormat,
                    status: _chipStatus(0, activeIndex),
                    accent: primary,
                  ),
                  _PrayerChip(
                    icon: Images.ModernPrayer_DhuhrSun,
                    name: prayerData?.isJumma == true
                        ? 'jumuah'.tr
                        : 'dhuhr'.tr,
                    time: prayerData?.zuhrStart ?? '00:00',
                    is24HourFormat: is24HourFormat,
                    status: _chipStatus(1, activeIndex),
                    accent: primary,
                  ),
                  _PrayerChip(
                    icon: Images.ModernPrayer_AsrCloudy,
                    name: 'asr'.tr,
                    time: prayerData?.asrStart ?? '00:00',
                    is24HourFormat: is24HourFormat,
                    status: _chipStatus(2, activeIndex),
                    accent: primary,
                  ),
                  _PrayerChip(
                    icon: Images.ModernPrayer_MaghribSunset,
                    name: 'magrib'.tr,
                    time: prayerData?.maghribStart ?? '00:00',
                    is24HourFormat: is24HourFormat,
                    status: _chipStatus(3, activeIndex),
                    accent: primary,
                  ),
                  _PrayerChip(
                    icon: Images.ModernPrayer_IshaMoon,
                    name: 'isha'.tr,
                    time: prayerData?.ishaStart ?? '00:00',
                    is24HourFormat: is24HourFormat,
                    status: _chipStatus(4, activeIndex),
                    accent: primary,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChipStatus { passed, active, upcoming }

class _PrayerChip extends StatelessWidget {
  final String icon;
  final String name;
  final String time;
  final bool is24HourFormat;
  final _ChipStatus status;
  final Color accent;
  final bool isLast;

  const _PrayerChip({
    required this.icon,
    required this.name,
    required this.time,
    required this.is24HourFormat,
    required this.status,
    required this.accent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == _ChipStatus.active;
    final onActive = Color.lerp(accent, Colors.black, 0.35)!;
    return Container(
      width: 64,
      height: _ModernNextPrayerCardState._chipHeight,
      margin: EdgeInsets.only(right: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(icon, height: 28),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize: 12,
              color: isActive ? onActive : Colors.white,
            ),
          ),
          Text(
            translateText(DateConverter.formatPrayerTime(time, is24HourFormat)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(
              fontSize: 11,
              color: isActive ? onActive.withOpacity(0.85) : Colors.white70,
            ),
          ),
          _StatusGlyph(
            status: status,
            color: isActive ? accent : Colors.white70,
          ),
        ],
      ),
    );
  }
}

class _StatusGlyph extends StatelessWidget {
  final _ChipStatus status;
  final Color color;
  const _StatusGlyph({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _ChipStatus.passed:
        return Icon(Icons.check, size: 12, color: color);
      case _ChipStatus.active:
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case _ChipStatus.upcoming:
        return Icon(
          Icons.circle_outlined,
          size: 10,
          color: color.withOpacity(0.8),
        );
    }
  }
}