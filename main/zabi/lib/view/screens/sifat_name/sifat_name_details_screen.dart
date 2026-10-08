// ignore_for_file: deprecated_member_use

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';

class SifatNameDetailsScreen extends StatelessWidget {
  final bool appBackButton;
  const SifatNameDetailsScreen({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranController>(
      builder: (sifatNameDetailsController) {
        var apiData = sifatNameDetailsController.sifatnameDetailsApidata;
        return Scaffold(
          // Appbar start ===>
          appBar: CustomAppBar(
            title: sifatNameDetailsController.isSifatNameDetailsLoading.value ||
                    sifatNameDetailsController.sifatnameDetailsApidata == null
                ? "--"
                : apiData!.data!.enName.toString(),
            isBackButtonExist: appBackButton == true ? true : false,
          ),

          // body start===>
          body: sifatNameDetailsController.isSifatNameDetailsLoading.value ||
                  sifatNameDetailsController.sifatnameDetailsApidata == null
              ? const AllahNameDetailsShimmer()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                        vertical: Dimensions.PADDING_SIZE_DEFAULT),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // bismillah image
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: SvgPicture.asset(
                            Images.Bismillah,
                            height: 50,
                            fit: BoxFit.fitHeight,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),

                        // english name ==>
                        Center(
                          child: Text(
                            apiData!.data!.enName.toString(),
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT),
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 30),

                        // arabic name ==>
                        Center(
                          child: Text(
                            apiData.data!.arName.toString(),
                            style: Get.find<SettingsController>()
                                .selectedArabicFont.copyWith(
                              fontSize: Get.find<SettingsController>()
                                  .arabicFontSize
                                  .value,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Divider(),

                        // name title ===>
                        Center(
                          child: Text(
                            apiData.data!.translatedName.toString(),
                            textAlign: TextAlign.center,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                        ),
                        const Divider(),

                        // meaning ===>
                        Text(
                          "meaning".tr,
                          textAlign: TextAlign.start,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_OVER_LARGE),
                        ),
                        const SizedBox(height: 10),

                        // name meaning ===>
                        Text(
                          apiData.data!.meaning.toString(),
                          textAlign: TextAlign.justify,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),

                        const Divider(),

                        // meaning ===>
                        Text(
                          "benefits".tr,
                          textAlign: TextAlign.start,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_OVER_LARGE),
                        ),
                        const SizedBox(height: 10),

                        // name meaning ===>
                        Text(
                          apiData.data!.nameBenefits.toString(),
                          textAlign: TextAlign.justify,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
