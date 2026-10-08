// ignore_for_file: deprecated_member_use, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';

import '../../../../controller/bookmark_controller.dart';
import '../../../../controller/internet_check_controller.dart';
import '../../../../controller/quran_settings_controller.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';
import '../../../base/loading_indicator.dart';
import '../../offline_quran/offline_surah_detail_screen.dart';

class BookmarkTab extends StatelessWidget {
  BookmarkTab({super.key});

  final BookMarkController bookMarkController = Get.put(BookMarkController());
  final internetController = Get.put(InternetController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (bookMarkController.isLoading.value) {
        return const Center(child: QuranListShimmer());
      } else {
        return bookMarkController.bookMarks.isEmpty
            ? Center(
                child: SizedBox(
                  height: 600,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "no_bookmarks_have_been_added_here".tr,
                      textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                ),
                shrinkWrap: true,
                primary: false,
                itemCount: bookMarkController.bookMarks.length,
                itemBuilder: (context, index) {
                  final bookMark = bookMarkController.bookMarks[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL + 3,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.RADIUS_LARGE,
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          if (internetController.hasInternet.value == false) {
                            Get.to(
                              () => OfflineSuraDetaileScreen(
                                appBackButton: true,
                                surahNumber: bookMark.serialNumber,
                              ),
                              arguments: int.parse(bookMark.pageKey),
                            );
                          } else {
                            Get.find<QuranController>().suraNumber = int.parse(
                              bookMark.serialNumber,
                            );
                            Get.find<QuranController>().fetchSuraDetaileData(
                              suraId: bookMark.serialNumber.toString(),
                            );
                            Get.toNamed(
                              RouteHelper.suraDetaile,
                              arguments: bookMark.pageKey,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(
                            Dimensions.PADDING_SIZE_DEFAULT,
                          ),
                          child: Column(
                            children: [
                              // arabic ayah ==>
                              Obx(
                                () => Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    bookMark.arabicName,
                                    maxLines: 3,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style: Get.find<SettingsController>()
                                        .selectedArabicFont
                                        .copyWith(
                                          fontSize:
                                              Get.find<SettingsController>()
                                                  .arabicFontSize
                                                  .value,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.color,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // translation aysh ==>
                              Obx(
                                () => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    bookMark.translatedName,
                                    textAlign: TextAlign.left,
                                    style: robotoMedium.copyWith(
                                      fontSize: Get.find<SettingsController>()
                                          .translateFontSize
                                          .value,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium!.color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Divider(),

                              // sura info ===>
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Obx(
                                    () => Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: "${"sura_name".tr}: ",
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Get.find<SettingsController>()
                                                      .translateFontSize
                                                      .value +
                                                  2,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium!.color,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: bookMark.suraName,
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Get.find<
                                                            SettingsController
                                                          >()
                                                          .translateFontSize
                                                          .value +
                                                      2,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium!.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${"sura_number".tr}: ${bookMark.serialNumber}"
                                              .tr,
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Get.find<SettingsController>()
                                                    .translateFontSize
                                                    .value,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        bookMark.versesNumber == ""
                                            ? const SizedBox()
                                            : Text(
                                                "${"ayah_no".tr}: ${bookMark.versesNumber}",
                                                style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Get.find<
                                                            SettingsController
                                                          >()
                                                          .translateFontSize
                                                          .value,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium!.color,
                                                ),
                                              ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "${"page_no".tr}: ${bookMark.pageNumber}",
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Get.find<SettingsController>()
                                                    .translateFontSize
                                                    .value,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Obx(
                                            () => AlertDialog(
                                              title:
                                                  bookMarkController
                                                          .isLoading
                                                          .value ==
                                                      true
                                                  ? Text(
                                                      'deleting_data'.tr,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            color: Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE,
                                                          ),
                                                    )
                                                  : Text(
                                                      'are_you_sure'.tr,
                                                      style: robotoMedium
                                                          .copyWith(
                                                            color: Theme.of(
                                                              context,
                                                            ).primaryColor,
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE,
                                                          ),
                                                    ),
                                              content:
                                                  bookMarkController
                                                          .isLoading
                                                          .value ==
                                                      true
                                                  ? const SizedBox(
                                                      height: 40,
                                                      child: Center(
                                                        child:
                                                            LoadingIndicator(),
                                                      ),
                                                    )
                                                  : Text(
                                                      "do_you_want_to_delete_this_bookmark"
                                                          .tr,
                                                      style: robotoMedium,
                                                    ),
                                              actions: [
                                                bookMarkController
                                                            .isLoading
                                                            .value ==
                                                        true
                                                    ? const SizedBox()
                                                    : TextButton(
                                                        onPressed: () {
                                                          var isLoading =
                                                              bookMarkController
                                                                  .isLoading(
                                                                    true,
                                                                  );

                                                          isLoading == true
                                                              ? Future.delayed(
                                                                  const Duration(
                                                                    seconds: 1,
                                                                  ),
                                                                  () {
                                                                    Get.back();
                                                                    bookMarkController
                                                                        .deleteBookMark(
                                                                          bookMark
                                                                              .id,
                                                                        );

                                                                    bookMarkController
                                                                        .isLoading(
                                                                          false,
                                                                        );
                                                                  },
                                                                )
                                                              : null;
                                                        },
                                                        child: Text(
                                                          'yes'.tr,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.error,
                                                              ),
                                                        ),
                                                      ),
                                                bookMarkController
                                                            .isLoading
                                                            .value ==
                                                        true
                                                    ? const SizedBox()
                                                    : TextButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: Text(
                                                          'cancel'.tr,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                color: Theme.of(
                                                                  context,
                                                                ).primaryColor,
                                                              ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
      }
    });
  }
}
