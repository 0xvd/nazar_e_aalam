import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/styles.dart';

// void showCustomSnackBar(
//   String message, {
//   bool isError = true,
//   Function()? onTap,
// }) {
//   if (Get.isSnackbarOpen) {
//     Get.closeCurrentSnackbar();
//   }

//   Get.showSnackbar(
//     GetSnackBar(
//       backgroundColor: isError ? Colors.red : Colors.green,
//       message: message,
//       duration: const Duration(seconds: 3),
//       snackPosition: SnackPosition.TOP,
//       margin: const EdgeInsets.all(10),
//       borderRadius: 10,
//       onTap: onTap != null ? (_) => onTap() : null,
//     ),
//   );
// }

void showCustomSnackBar(
  String message, {
  bool isError = false,
  Function()? onTap,
}) {
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

  Get.rawSnackbar(
    onTap: onTap != null ? (_) => onTap() : null,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.symmetric(horizontal: 00, vertical: 10),
    borderRadius: 26,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    backgroundColor: Colors.transparent,
    isDismissible: true,
    snackStyle: SnackStyle.FLOATING,
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 450),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    overlayBlur: 0.0,
    messageText: GestureDetector(
      onTap: () {
        Get.closeCurrentSnackbar();
        // Optional: Add navigation or retry logic here
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: Get.isDarkMode
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.09),
                    blurRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isError
                        ? CupertinoIcons.exclamationmark_triangle
                        : CupertinoIcons.checkmark_circle,
                    color: isError
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF34C759),
                    size: 26,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: robotoMedium.copyWith(
                        color: Get.isDarkMode
                            ? Colors.white.withValues(alpha: 0.95)
                            : Colors.black.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
      ),
    ),
  );
}
