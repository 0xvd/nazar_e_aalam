// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/offline_quran_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/offline_surah_detail_screen.dart';

import '../../../controller/quran_settings_controller.dart';

class OfflineJuzListWidget extends StatelessWidget {
  const OfflineJuzListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final juzListController = Get.put(OfflineQuranController());
    juzListController.loadJuzzList();
    return SingleChildScrollView(
      child: GetBuilder<OfflineQuranController>(
        builder: (juzListController) {
          return Obx(
            () =>
                juzListController.isJuzzLoading.value ||
                    juzListController.juzListApiData == null
                ? const Center(child: LoadingIndicator())
                : Column(
                    children: [
                      for (
                        var juz = 0;
                        juz < juzListController.juzListApiData!.data!.length;
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
                                " ${juzListController.juzListApiData!.data![juz].juzTranslateName}: ${juzListController.juzListApiData!.data![juz].juzNumber}",
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
                              itemCount: juzListController
                                  .juzListApiData!
                                  .data![juz]
                                  .chapterList!
                                  .length,
                              itemBuilder: (context, index) {
                                var apiData = juzListController
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
                                        juzListController.lastSurahNumber =
                                            apiData.chapterId!;
                                        Get.to(
                                          () => OfflineSuraDetaileScreen(
                                            appBackButton: true,
                                            surahNumber: apiData.chapterId!
                                                .toString(),
                                          ),
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
                                                end: Dimensions
                                                    .PADDING_SIZE_SMALL,
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
                                                    Get.find<
                                                        SettingsController
                                                        >()
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
                                                    Get.find<
                                                        SettingsController
                                                        >()
                                                        .translateFontSize
                                                        .value -
                                                    3,
                                              ),
                                            ),
                                          ),
                                          trailing: Obx(
                                            () => Text(
                                              apiData.arabicName.toString(),
                                              style:
                                                  Get.find<
                                                      SettingsController
                                                      >()
                                                      .selectedArabicFont
                                                      .copyWith(
                                                        fontSize:
                                                            Get.find<
                                                                SettingsController
                                                                >()
                                                                .arabicFontSize
                                                                .value,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
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
                  ),
          );
        },
      ),
    );
  }
}
