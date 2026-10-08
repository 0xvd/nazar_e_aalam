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
import 'package:nazar_e_alam/view/screens/wallpapers/widget/set_wallpaper_dialog.dart';

import '../../base/cutom_cached_image.dart';

class WallpaperDetailsScreen extends StatelessWidget {
  final String categoryName;
  const WallpaperDetailsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final wallPaperController = Get.find<WallPaperController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wallPaperController.wallpaperCategoryListDetails(categoryName);
    });

    return GetBuilder<WallPaperController>(
      builder: (wallPaperController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "wallpapers_details_key".tr,
            isBackButtonExist: true,
          ),
          body: wallPaperController.isWallPaperListLoading.value ||
                  wallPaperController.wallpaperModelData == null
              ? const WallpaperDetailsTypeShimmer()
              : Padding(
                  padding: const EdgeInsets.all(
                    Dimensions.PADDING_SIZE_DEFAULT,
                  ),
                  child: GridView.builder(
                    itemCount: wallPaperController.filteredWallpapers.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: 326,
                    ),
                    itemBuilder: (context, index) {
                      var apiData =
                          wallPaperController.filteredWallpapers[index];

                      return InkWell(
                        onTap: () {
                          apiData.wallpaper == null ||
                                  apiData.wallpaper!.isEmpty
                              ? null
                              : Get.dialog(SetWallpaperDialogWidget(
                                  imagePath: "${apiData.wallpaper}",
                                ));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 300,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Get.isDarkMode
                                      ? Theme.of(context).disabledColor
                                      : AppColor.hoverBlueColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3))),
                              child: CachedNetworkImageWidget(
                                imageUrl: apiData.wallpaper ?? '',
                                height: 300,
                                width: double.infinity,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              apiData.name ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
