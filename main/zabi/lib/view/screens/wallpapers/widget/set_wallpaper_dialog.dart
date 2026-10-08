import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:nazar_e_alam/controller/wallpaper_controller.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';

class SetWallpaperDialogWidget extends StatelessWidget {
  final String imagePath;
  const SetWallpaperDialogWidget({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.none,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        child: GetBuilder<WallPaperController>(
          builder: (wallPaperController) {
            return Stack(
              children: [
                ClipRRect(
                  child: RepaintBoundary(
                    key: wallPaperController.previewContainer,
                    child: PhotoView(
                      // customSize: Size.fromHeight(Get.height),
                      minScale: PhotoViewComputedScale.covered,
                      initialScale: PhotoViewComputedScale.covered,
                      // Allow zooming out or in
                      maxScale: PhotoViewComputedScale.covered,
                      enableRotation: false, // Optional: disable rotation
                      disableGestures:
                          true, // Completely disable gestures (if you want no pan/zoom at all)
                      filterQuality: FilterQuality.high,
                      imageProvider: imagePath.startsWith("http")
                          ? NetworkImage(imagePath)
                          : FileImage(
                              File(
                                imagePath,
                              ),
                            ) as ImageProvider,
                      loadingBuilder: (context, event) => Center(
                        child: LoadingIndicator(),
                      ),
                      backgroundDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          wallPaperController.shareFilePdf(imagePath);
                        },
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle),
                          child: Center(
                              child: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 18,
                          )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Platform.isAndroid
                          ? InkWell(
                              onTap: () {
                                wallPaperController.handleUseAs(context);
                              },
                              child: Container(
                                height: 35,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12.0, left: 12.0),
                                    child: Text(
                                      "set_wallpaper_key".tr,
                                      style: robotoMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
