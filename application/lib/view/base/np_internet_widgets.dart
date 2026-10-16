// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/styles.dart';

void showNoInternetDialog() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Get.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WiFi Off Icon
              Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: Get.isDarkMode ? Colors.red[300] : Colors.red,
              ),
              const SizedBox(height: 15),

              // Title
              Text(
                "No_Internet_Connection".tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                "Check_your_internet_connection_and_try_again".tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  color: Get.isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 25),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.isDarkMode
                        ? Colors.red[400]
                        : Colors.red, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    "OK".tr,
                    style: robotoBlack.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
