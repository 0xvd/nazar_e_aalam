// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/view/screens/language/language_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/notification/notification_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/prayer_settings/prayer_calculation_settings.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/home_layout_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/item_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final bool appBackButton;
  const SettingsScreen({super.key, required this.appBackButton});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: 'settings'.tr,
        isBackButtonExist: widget.appBackButton == true ? true : false,
      ),

      body: GetBuilder<SettingsController>(
        builder: (settingsController) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
              ),
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  // Prayer Time Calculation Settings Section
                  const PrayerTimeCalculationSettings(),

                  // Notification section
                  const NofificationDWWidget(),

                  // select language section
                  const LanguageDWWidget(),

                  // home screen layout (appearance) section
                  const HomeLayoutDWWidget(),

                  // share and rate app section  for android.
                  Platform.isAndroid
                      ? Column(
                          children: [
                            if (settingsController.mosqueSettingsApiData !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data!
                                        .playStoreUrl !=
                                    null)
                              SettingsItem(
                                leadingIcon: Icons.share,
                                imagePath: Images.Icon_share_app,
                                title: 'share'.tr,
                                onTap: () async {
                                  final playStoreUrl = settingsController
                                      .mosqueSettingsApiData!
                                      .data!
                                      .playStoreUrl
                                      .toString();
                                  if (Uri.tryParse(playStoreUrl) != null) {
                                    await Share.share(playStoreUrl);
                                  } else {
                                    showCustomSnackBar(
                                      "invalid_URL".tr,
                                      isError: true,
                                    );
                                  }
                                },
                              ),
                            if (settingsController.mosqueSettingsApiData !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data!
                                        .playStoreUrl !=
                                    null)
                              SettingsItem(
                                imagePath: Images.Icon_rate_app,
                                leadingIcon: Icons.rate_review,
                                title: 'rate_us'.tr,
                                onTap: () async {
                                  final playStoreUrl = settingsController
                                      .mosqueSettingsApiData!
                                      .data!
                                      .playStoreUrl
                                      .toString();
                                  if (Uri.tryParse(playStoreUrl) != null) {
                                    final url = Uri.parse(playStoreUrl);
                                    launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    showCustomSnackBar(
                                      "invalid_URL".tr,
                                      isError: true,
                                    );
                                  }
                                },
                              ),
                          ],
                        )
                      : const SizedBox(),

                  // share and rate app section  for ios
                  Platform.isIOS
                      ? Column(
                          children: [
                            if (settingsController.mosqueSettingsApiData !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data!
                                        .appStoreUrl !=
                                    null)
                              SettingsItem(
                                imagePath: Images.Icon_share_app,
                                leadingIcon: Icons.share,
                                title: 'share'.tr,
                                onTap: () async {
                                  final appStoreUrl = settingsController
                                      .mosqueSettingsApiData!
                                      .data!
                                      .appStoreUrl
                                      .toString();
                                  if (Uri.tryParse(appStoreUrl) != null) {
                                    await Share.share(appStoreUrl);
                                  } else {
                                    showCustomSnackBar(
                                      "invalid_URL".tr,
                                      isError: true,
                                    );
                                  }
                                },
                              ),
                            if (settingsController.mosqueSettingsApiData !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data !=
                                    null &&
                                settingsController
                                        .mosqueSettingsApiData!
                                        .data!
                                        .appStoreUrl !=
                                    null)
                              SettingsItem(
                                imagePath: Images.Icon_rate_app,
                                leadingIcon: Icons.rate_review,
                                title: 'rate_us'.tr,
                                onTap: () async {
                                  final appStoreUrl = settingsController
                                      .mosqueSettingsApiData!
                                      .data!
                                      .appStoreUrl
                                      .toString();
                                  if (Uri.tryParse(appStoreUrl) != null) {
                                    final url = Uri.parse(appStoreUrl);
                                    launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    showCustomSnackBar(
                                      "invalid_URL".tr,
                                      isError: true,
                                    );
                                  }
                                },
                              ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
