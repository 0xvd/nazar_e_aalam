// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/wallpaper_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/screens/wallpapers/details_screen.dart';

import '../../base/cutom_cached_image.dart';
import 'widget/set_wallpaper_dialog.dart';

class WallpaperScreens extends StatelessWidget {
  final bool? appBackButton;
  const WallpaperScreens({super.key, this.appBackButton});

  @override
  Widget build(BuildContext context) {
    Get.find<WallPaperController>().wallpaperCategoryListData();

    return GetBuilder<WallPaperController>(
      builder: (wallPaperController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "wallpapers_key".tr,
            isBackButtonExist: appBackButton == true ? true : false,
          ),
          body:
              wallPaperController.isWallPaperListLoading.value ||
                  wallPaperController.wallpaperModelData == null
              ? const WallpaperListTypeShimmer()
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: ListView.builder(
                    itemCount:
                        wallPaperController.wallpaperModelData?.data?.length,
                    primary: false,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_SMALL,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      var apiData =
                          wallPaperController.wallpaperModelData?.data![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 10.0,
                              right: 10,
                            ),
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  () => WallpaperDetailsScreen(
                                    categoryName: '${apiData?.category}',
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${apiData?.category}",
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            height: 230,
                            child: ListView.builder(
                              itemCount: apiData?.wallpapers?.length,
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                var wallpaperData = apiData?.wallpapers?[index];

                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      wallpaperData?.wallpaper == null ||
                                              wallpaperData!.wallpaper!.isEmpty
                                          ? null
                                          : Get.dialog(
                                              SetWallpaperDialogWidget(
                                                imagePath:
                                                    "${wallpaperData.wallpaper}",
                                              ),
                                            );
                                    },
                                    child: Container(
                                      height: 230,
                                      width: Get.width * 0.3,
                                      decoration: BoxDecoration(
                                        color: Get.isDarkMode
                                            ? Theme.of(context).disabledColor
                                            : AppColor.hoverBlueColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          width: 1,
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.2),
                                        ),
                                      ),
                                      child: CachedNetworkImageWidget(
                                        imageUrl:
                                            wallpaperData?.wallpaper ?? '',
                                        height: 230,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
