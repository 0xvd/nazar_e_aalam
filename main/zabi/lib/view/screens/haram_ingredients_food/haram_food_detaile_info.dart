import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

class HaramFoodDetaileInfoScreen extends StatelessWidget {
  final bool appBackButton;
  const HaramFoodDetaileInfoScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    Get.find<SettingsController>().fetchMosqueSettingsData();

    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: 'haram_ingredients_food_details'.tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),

      // body start ==>
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(
            children: [
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Text(
                Get.find<SettingsController>()
                    .mosqueSettingsApiData!
                    .data!
                    .haramDescription
                    .toString(),
                textAlign: TextAlign.justify,
                style: robotoMedium.copyWith(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
