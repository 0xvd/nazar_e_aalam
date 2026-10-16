// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class JuzListWidget extends StatelessWidget {
  const JuzListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<QuranController>().fetchJuzListData();
    return SingleChildScrollView(
      child: GetBuilder<QuranController>(
        builder: (quranController) {
          return quranController.isJuzListLoading.value ||
                  quranController.juzListApiData == null
              ? const Center(child: QuranListShimmer())
              : Column(
                  children: [
                    for (
                      var juz = 0;
                      juz < quranController.juzListApiData!.data!.length;
                      juz++
                    )
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // juz name ===>
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.FONT_SIZE_DEFAULT,
                            ),
                            child: Text(
                              " ${quranController.juzListApiData!.data![juz].juzTranslateName}: ${quranController.juzListApiData!.data![juz].juzNumber}",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          // list view ===>
                          ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            itemCount: quranController
                                .juzListApiData!
                                .data![juz]
                                .chapterList!
                                .length,
                            itemBuilder: (context, index) {
                              var apiData = quranController
                                  .juzListApiData!
                                  .data![juz]
                                  .chapterList![index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // card start ==>
                                  GestureDetector(
                                    onTap: () {
                                      Get.find<QuranController>().suraNumber =
                                          apiData.chapterId;
                                      Get.find<QuranController>()
                                          .fetchSuraDetaileData(
                                            suraId: apiData.chapterId
                                                .toString(),
                                          );
                                      Get.toNamed(
                                        RouteHelper.suraDetaile,
                                        arguments: 0,
                                      );
                                    },
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      color: Theme.of(context).cardColor,
                                      shadowColor: Get.isDarkMode
                                          ? Colors.grey[800]!
                                          : Colors.grey[200]!,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsetsDirectional.only(
                                              start: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL,
                                              end:
                                                  Dimensions.PADDING_SIZE_SMALL,
                                            ),
                                        leading: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              Images.Icon_Star,
                                              height: 50,
                                              fit: BoxFit.fill,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            Text(
                                              apiData.serialNumber.toString(),
                                              style: robotoMedium.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium!.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Obx(
                                          () => Text(
                                            apiData.translatedName.toString(),
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Get.find<SettingsController>()
                                                      .translateFontSize
                                                      .value,
                                            ),
                                          ),
                                        ),
                                        subtitle: Obx(
                                          () => Text(
                                            "${apiData.versesTranslateName}: ${apiData.verseNumber}",
                                            style: robotoMedium.copyWith(
                                              fontSize:
                                                  Get.find<SettingsController>()
                                                      .translateFontSize
                                                      .value -
                                                  3,
                                            ),
                                          ),
                                        ),
                                        trailing: Obx(
                                          () => Text(
                                            apiData.arabicName.toString(),
                                            style: Get.find<SettingsController>()
                                                .selectedArabicFont
                                                .copyWith(
                                                  fontSize:
                                                      Get.find<
                                                            SettingsController
                                                          >()
                                                          .arabicFontSize
                                                          .value,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge!.color,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                );
        },
      ),
    );
  }
}
