// models/prayer_item.dart
import 'package:flutter/material.dart';

class PrayerItem {
  final String key;
  final String name;
  final String defaultTime;
  final String icon;
  final List<Color> gradient;

  PrayerItem({
    required this.key,
    required this.name,
    required this.defaultTime,
    required this.icon,
    required this.gradient,
  });

  DateTime get time {
    try {
      final parts = defaultTime.split(':');
      return DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}
