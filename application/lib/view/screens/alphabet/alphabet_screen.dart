import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import 'alphabet_setting_sheet.dart';
import 'widget/arabic_alphabet_grid.dart';

class AlphabetScreen extends StatelessWidget {
  final bool? appBackButton;
  const AlphabetScreen({super.key, this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: appBackButton == true ? true : false,
        title: 'alphabet_key'.tr,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openAlphabetSettings(context),
          ),
        ],
      ),

      body: const SingleChildScrollView(child: ArabicAlphabetGrid()),
    );
  }
}
