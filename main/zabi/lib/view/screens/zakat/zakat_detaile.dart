import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class ZakatDetaile extends StatelessWidget {
  final bool appBackButton;
  const ZakatDetaile({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    Get.find<SettingsController>().fetchMosqueSettingsData();
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: "about_zakat".tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),

      // body start
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_DEFAULT),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Text(
                Get.find<SettingsController>()
                    .mosqueSettingsApiData!
                    .data!
                    .zakatDescription
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
