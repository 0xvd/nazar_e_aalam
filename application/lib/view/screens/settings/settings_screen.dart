// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
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
  /// Store link for the current platform (null when not available).
  String? _storeUrl(SettingsController c) {
    final data = c.mosqueSettingsApiData?.data;
    if (data == null) return null;
    final url = Platform.isIOS ? data.appStoreUrl : data.playStoreUrl;
    final s = url?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  Future<void> _share(String url) async {
    if (Uri.tryParse(url) != null) {
      await Share.share(url);
    } else {
      showCustomSnackBar('invalid_URL'.tr, isError: true);
    }
  }

  Future<void> _rate(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('invalid_URL'.tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // As a tab in modern layout the page sits behind the floating glass bar.
    final modern = Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    final bottomPad = (modern && !widget.appBackButton) ? 120.0 : 16.0;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'settings'.tr,
        isBackButtonExist: widget.appBackButton,
      ),
      body: GetBuilder<SettingsController>(
        builder: (settingsController) {
          final storeUrl = _storeUrl(settingsController);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Dimensions.PADDING_SIZE_EXTRA_SMALL,
              Dimensions.PADDING_SIZE_EXTRA_SMALL,
              Dimensions.PADDING_SIZE_EXTRA_SMALL,
              bottomPad,
            ),
            child: Column(
              children: [
                const PrayerTimeCalculationSettings(),
                const NofificationDWWidget(),
                const LanguageDWWidget(),
                const HomeLayoutDWWidget(),
                if (storeUrl != null) ...[
                  SettingsItem(
                    leadingIcon: Icons.share,
                    imagePath: Images.Icon_share_app,
                    title: 'share'.tr,
                    onTap: () => _share(storeUrl),
                  ),
                  SettingsItem(
                    leadingIcon: Icons.rate_review,
                    imagePath: Images.Icon_rate_app,
                    title: 'rate_us'.tr,
                    onTap: () => _rate(storeUrl),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}