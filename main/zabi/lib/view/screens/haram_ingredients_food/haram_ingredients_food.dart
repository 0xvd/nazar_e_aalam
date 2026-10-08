// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import '../../../data/model/response/haram_food_list_model.dart';

class HaramIngredientsFood extends StatelessWidget {
  final bool appBackButton;
  const HaramIngredientsFood({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) {
    Get.find<SettingsController>().fetchHaramFoodListData();
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: 'haram_ingredients_in_food'.tr,
        isBackButtonExist: appBackButton == true ? true : false,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(RouteHelper.haramFoodDetaile);
            },
            icon: SvgPicture.asset(Images.Icon_Details,
                height: 28,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyMedium!.color
                    : Theme.of(context).cardColor),
          )
        ],
      ),

      // start body ===>
      body: GetBuilder<SettingsController>(
        builder: (haramFoodListController) {
          return haramFoodListController.isDuaListLoading.value ||
                  haramFoodListController.haramFoodListApiData == null
              ? const Center(
                  child: HaramCodeShimmer(),
                )
              : haramFoodListController.haramFoodListApiData!.data!.isEmpty
                  ? Center(
                      child: Text(
                        "no_data_found".tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                        vertical: Dimensions.PADDING_SIZE_SMALL,
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 3
                              : 5,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: haramFoodListController
                            .haramFoodListApiData!.data!.length,
                        itemBuilder: (context, index) {
                          var apiData = haramFoodListController
                              .haramFoodListApiData!.data;
                          return GestureDetector(
                            onTap: () {
                              _showReciterDialog(
                                context,
                                haramFoodListController
                                    .haramFoodListApiData!.data![index],
                              );
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              color: Theme.of(context).cardColor,
                              elevation: 2.0,
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    Dimensions.PADDING_SIZE_SMALL),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 5),
                                      Text(
                                        apiData![index].code.toString(),
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.FONT_SIZE_DEFAULT,
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            apiData[index].name.toString(),
                                            textAlign: TextAlign.center,
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Dimensions.FONT_SIZE_SMALL,
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
                        },
                      ),
                    );
        },
      ),
    );
  }

// dialoge function ===>
  void _showReciterDialog(BuildContext context, Data codeInfo) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text(
            codeInfo.name.toString(),
            style: robotoMedium.copyWith(
              fontSize: Dimensions.FONT_SIZE_LARGE,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // code text ==>
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: "${'code'.tr}: ",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    TextSpan(
                      text: '${codeInfo.code}',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),

              // info text ==>
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: "${'information'.tr}: ".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: '${codeInfo.description}',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // status text ==>
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: "${'status'.tr}: ",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    // status text ==>
                    TextSpan(
                      text: '${codeInfo.statusInfo}',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // close buttion ==>
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'close'.tr,
                style: robotoMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}
