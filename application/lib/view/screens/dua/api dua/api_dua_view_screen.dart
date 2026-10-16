// ignore_for_file: deprecated_member_use

import 'package:nazar_e_alam/controller/dua_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/images.dart';
import '../../../../util/styles.dart';

class DuasViewScreen extends StatelessWidget {
  final bool appBackButton;
  const DuasViewScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DuaController>(
      builder: (duaDetailsController) {
        return Scaffold(
          // Appbar start ===>
          appBar: CustomAppBar(
            title: duaDetailsController.isDuaDetailsLoading.value ||
                    duaDetailsController.duaDetailApiData == null
                ? "--"
                : duaDetailsController.duaDetailApiData!.data!.enShortName
                    .toString(),
            isBackButtonExist: appBackButton == true ? true : false,
          ),

          body: GetBuilder<DuaController>(
            builder: (duaDetailsController) {
              return duaDetailsController.isDuaDetailsLoading.value ||
                      duaDetailsController.duaDetailApiData == null
                  ? const Center(
                      child: DhuaDetailsShimmer(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                        vertical: Dimensions.FONT_SIZE_SMALL,
                      ),
                      child: ListView(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // bismillah image ===>
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
                              const SizedBox(
                                  height: Dimensions.PADDING_SIZE_SMALL),
                              const Divider(),

                              // arabic string ===>
                              Text(
                                '${duaDetailsController.duaDetailApiData!.data!.arFullName}',
                                textAlign: TextAlign.right,
                                style: Get.find<SettingsController>()
                                    .selectedArabicFont
                                    .copyWith(
                                  fontSize: Get.find<SettingsController>()
                                      .arabicFontSize
                                      .value,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                              ),
                              const SizedBox(
                                  height: Dimensions.PADDING_SIZE_LARGE),

                              // english string ===>
                              Text(
                                "${duaDetailsController.duaDetailApiData!.data!.enFullName}",
                                textAlign: TextAlign.justify,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
            },
          ),
        );
      },
    );
  }
}
