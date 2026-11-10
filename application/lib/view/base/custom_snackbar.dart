import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/styles.dart';

void showCustomSnackBar(
  String message, {
  bool isError = false,
  Function()? onTap,
}) {
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

  final dark = Get.isDarkMode;
  final accent = isError ? const Color(0xFFE8202A) : const Color(0xFF00A650);
  final fill = dark
      ? const Color(0xFF221A14).withValues(alpha: 0.88)
      : Colors.white.withValues(alpha: 0.90);
  final textColor = dark ? const Color(0xFFFFF4E8) : const Color(0xFF1A1A1A);

  Get.rawSnackbar(
    onTap: onTap != null ? (_) => onTap() : null,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    borderRadius: 22,
    padding: EdgeInsets.zero,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    snackStyle: SnackStyle.FLOATING,
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 450),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    overlayBlur: 0.0,
    messageText: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.15),
                ),
                child: Icon(
                  isError
                      ? CupertinoIcons.exclamationmark_triangle_fill
                      : CupertinoIcons.checkmark_alt_circle_fill,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: robotoMedium.copyWith(color: textColor),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Get.closeCurrentSnackbar(),
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: Colors.grey.withValues(alpha: 0.5),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}