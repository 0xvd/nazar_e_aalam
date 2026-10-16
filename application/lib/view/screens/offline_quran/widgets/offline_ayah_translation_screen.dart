// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nazar_e_alam/controller/offline_quran_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';

import '../../../../controller/quran_settings_controller.dart';

class OfflineAyanTranslationWidget extends StatefulWidget {
  const OfflineAyanTranslationWidget({super.key});

  @override
  State<OfflineAyanTranslationWidget> createState() =>
      _OfflineAyanTranslationWidgetState();
}

class _OfflineAyanTranslationWidgetState
    extends State<OfflineAyanTranslationWidget> {
  final Map<int, GlobalKey> _verseKeys = {};
  @override
  Widget build(BuildContext context) {
    return GetBuilder<OfflineQuranController>(
      builder: (suraDetaileController) {
        if (suraDetaileController.isSurahDetailsLoading.value ||
            suraDetaileController.suraDetailsApiData == null) {
          return const Center(child: LoadingIndicator());
        }

        // Wrap in SizedBox + SingleChildScrollView + Column
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // allow scroll
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // your existing Bismillah card code...
              if (suraDetaileController.suraDetailsApiData!.data!.chapter!.id !=
                      1 &&
                  suraDetaileController.suraDetailsApiData!.data!.chapter!.id !=
                      9)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          Images.Bismillah,
                          height: 50,
                          fit: BoxFit.fitHeight,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

              // Replace outer ListView.builder with Column
              Column(
                children: List.generate(
                  suraDetaileController
                      .suraDetailsApiData!
                      .data!
                      .chapterInfo!
                      .length,
                  (index) {
                    var apiData = suraDetaileController
                        .suraDetailsApiData!
                        .data!
                        .chapterInfo![index];
                    return Column(
                      children: [
                        // inner ListView.builder remains unchanged
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: apiData.pageVerses!.length,
                          itemBuilder: (context, verseIndex) {
                            final verse = apiData.pageVerses![verseIndex];
                            int verseNumber = verse.versesNumber!;
                            // Create key for each verse
                            _verseKeys[verseNumber] = GlobalKey();
                            return SizedBox(
                              key: _verseKeys[verseNumber],
                              width: double.infinity,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                color: Theme.of(context).cardColor,
                                shadowColor: Get.isDarkMode
                                    ? Colors.grey[800]!
                                    : Colors.grey[200]!,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      // Arabic Ayah
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Obx(
                                          () => SelectableText(
                                            apiData
                                                .pageVerses![verseIndex]
                                                .arabicName
                                                .toString(),
                                            textDirection: TextDirection.rtl,
                                            textAlign: TextAlign.right,
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
                                                          .bodyMedium!
                                                          .color,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL,
                                      ),
                                      // Translation
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Obx(
                                          () => SelectableText(
                                            apiData
                                                .pageVerses![verseIndex]
                                                .translatedName
                                                .toString(),
                                            textAlign: TextAlign.justify,
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
                                      ),
                                      const SizedBox(
                                        height: Dimensions.PADDING_SIZE_SMALL,
                                      ),
                                      // end ayah row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                Images.Icon_End_Ayah,
                                                height: 45,
                                                fit: BoxFit.fill,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                              ),
                                              Text(
                                                apiData
                                                    .pageVerses![verseIndex]
                                                    .versesNumber
                                                    .toString(),
                                                style: robotoMedium.copyWith(
                                                  fontSize: Dimensions
                                                      .FONT_SIZE_SMALL,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium!.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Builder(
                                                builder: (buttonContext) {
                                                  return IconButton(
                                                    onPressed: () {
                                                      final box =
                                                          buttonContext
                                                                  .findRenderObject()
                                                              as RenderBox;

                                                      Share.share(
                                                        'Arabic Ayah: ${apiData.pageVerses![verseIndex].arabicName}\n\n'
                                                        'Translation: ${apiData.pageVerses![verseIndex].translatedName}\n\n'
                                                        'Sura Name: ${suraDetaileController.suraDetailsApiData!.data!.chapter!.translatedName}\n'
                                                        'Ayah Number: ${apiData.pageVerses![verseIndex].versesNumber}\n'
                                                        'Powered By: ${AppConstants.APP_NAME}',
                                                        sharePositionOrigin:
                                                            box.localToGlobal(
                                                              Offset.zero,
                                                            ) &
                                                            box.size,
                                                      );
                                                    },
                                                    icon: SvgPicture.asset(
                                                      Images.Icon_Share,
                                                      height: 28,
                                                      color: Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            apiData.pageNumber.toString(),
                            textAlign: TextAlign.justify,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
