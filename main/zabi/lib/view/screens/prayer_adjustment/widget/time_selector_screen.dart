// widgets/time_selector_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/helper/salat_waqt_service.dart';

import '../../../../controller/prayer_time_adjustment.dart';
import '../../../../helper/translator_helper.dart';
import '../../../../util/styles.dart';

class TimeSelectorScreen extends StatefulWidget {
  final String prayerKey;
  final String prayerName;
  final String defaultTime;
  final Function(String, int) onSave;
  final VoidCallback onCancel;

  const TimeSelectorScreen({
    super.key,
    required this.prayerKey,
    required this.prayerName,
    required this.defaultTime,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<TimeSelectorScreen> createState() => _TimeSelectorScreenState();
}

class _TimeSelectorScreenState extends State<TimeSelectorScreen> {
  final _controller = Get.find<PrayerTimeAdjustmentController>();

  late double _sliderValue;
  late DateTime _currentDisplayTime;

  @override
  void initState() {
    super.initState();

    final previousMinutes = _controller.getAdjustmentMinutes(widget.prayerKey);
    _sliderValue = (previousMinutes ?? 0) + 30.0;
    _updateDisplayTime();
  }

  String _getDisplayValue(double value) {
    final minutes = (value - 30.0).round();
    if (minutes == 0) return '${translateText("0")} ${"min".tr}';
    return '${minutes > 0 ? '+' : ''}$minutes ${"min".tr}';
  }

  void _updateDisplayTime() {
    final minutes = (_sliderValue - 30.0).round();

    try {
      final parts = widget.defaultTime.split(':');
      final baseTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      _currentDisplayTime = baseTime.add(Duration(minutes: minutes));
    } catch (e) {
      _currentDisplayTime = DateTime.now();
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isSliderAtZero() {
    return (_sliderValue - 30.0).round() == 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAtZero = _isSliderAtZero();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: Container(
            width: Get.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: theme.primaryColor.withValues(
                      alpha: Get.isDarkMode ? 0.3 : 0.09,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(Icons.schedule, color: theme.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.prayerName,
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              translateText(_formatTime(_currentDisplayTime)),
                              style: robotoRegular.copyWith(
                                fontSize: 14,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: theme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: IconButton(
                          onPressed: widget.onCancel,
                          icon: Icon(
                            Icons.close_outlined,
                            color: Colors.redAccent.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Slider Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      // Current adjustment display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'adjustment'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: 16,
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              translateText(_getDisplayValue(_sliderValue)),
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 14,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                          activeTrackColor: theme.primaryColor,
                          inactiveTrackColor: theme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          thumbColor: theme.primaryColor,
                          overlayColor: theme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          valueIndicatorColor: theme.primaryColor,
                          showValueIndicator: ShowValueIndicator.alwaysVisible,
                        ),
                        child: Slider(
                          value: _sliderValue,
                          min: 0,
                          max: 60,
                          divisions: 60,
                          // label: _getDisplayValue(_sliderValue),
                          onChanged: (value) {
                            setState(() {
                              _sliderValue = value;
                              _updateDisplayTime();
                            });
                          },
                        ),
                      ),

                      // Slider labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              translateText('-30 ${"min".tr}'),
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                            Text(
                              translateText('-15 ${"min".tr}'),
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                            Text(
                              translateText('0 ${"min".tr}'),
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                            Text(
                              translateText('+15 ${"min".tr}'),
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                            Text(
                              translateText('+30 ${"min".tr}'),
                              style: robotoRegular.copyWith(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isAtZero
                              ? null
                              : () async {
                                  setState(() {
                                    _sliderValue = 30.0;
                                    _updateDisplayTime();
                                  });

                                  await _controller.resetPrayerTime(
                                    prayerKey: widget.prayerKey,
                                  );

                                  Get.back();
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: isAtZero
                                  ? theme.hintColor.withValues(alpha: 0.2)
                                  : theme.primaryColor.withValues(alpha: 0.3),
                            ),
                            disabledForegroundColor: theme.hintColor.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Obx(() {
                            if (_controller.isResetting.value) {
                              return SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.primaryColor,
                                ),
                              );
                            }
                            return Text(
                              'reset'.tr,
                              style: robotoMedium.copyWith(
                                color: isAtZero
                                    ? theme.hintColor.withValues(alpha: 0.3)
                                    : theme.primaryColor,
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isAtZero
                              ? null
                              : () {
                                  final minutes = (_sliderValue - 30.0).round();
                                  widget.onSave(widget.prayerKey, minutes);
                                  SalatWaqtService.initializeSalatWaqt();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAtZero
                                ? theme.hintColor.withValues(alpha: 0.2)
                                : theme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: theme.hintColor.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Text(
                            'save'.tr,
                            style: robotoMedium.copyWith(
                              color: isAtZero
                                  ? theme.hintColor.withValues(alpha: 0.5)
                                  : Colors.white,
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
        ),
      ),
    );
  }
}
