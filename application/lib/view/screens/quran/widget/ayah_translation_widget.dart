// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class AyanTranslationWidget extends StatelessWidget {
  const AyanTranslationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<QuranController>(
        builder: (quranController) {
          if (quranController.isSuraDetaileLoading.value ||
              quranController.suraDetaileApiData == null) {
            return const Center(
              child: SingleChildScrollView(child: AyahTranslationShimmer()),
            );
          }

          final chapter = quranController.suraDetaileApiData!.data!.chapter!;
          final chapterInfo =
              quranController.suraDetaileApiData!.data!.chapterInfo!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (chapter.id != 1 && chapter.id != 9) _buildBismillah(context),
              ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                ),
                itemCount: chapterInfo.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, chapterIndex) {
                  final chapterData = chapterInfo[chapterIndex];
                  return _buildChapterCardList(
                    context,
                    quranController,
                    chapterData,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBismillah(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _buildChapterCardList(
    BuildContext context,
    QuranController controller,
    dynamic chapterData,
  ) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chapterData.pageVerses!.length,
          itemBuilder: (context, verseIndex) {
            final verse = chapterData.pageVerses![verseIndex];
            return _buildVerseCard(context, controller, verse);
          },
        ),
        const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        Text(
          chapterData.pageNumber.toString(),
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.FONT_SIZE_LARGE,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
      ],
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    QuranController controller,
    dynamic verse,
  ) {
    final settings = Get.find<SettingsController>();

    return SizedBox(
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        shadowColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arabic Ayah
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => SelectableText(
                    verse.arabicName.toString(),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: Get.find<SettingsController>().selectedArabicFont
                        .copyWith(
                          fontSize: settings.arabicFontSize.value,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

              // Transliteration
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(
                    Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SelectableText(
                    verse.transLiteration.toString(),
                    textAlign: TextAlign.justify,
                    style: robotoMedium.copyWith(
                      fontSize: settings.translateFontSize.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Divider(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                height: 1,
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

              // Translation
              Obx(
                () => SelectableText(
                  verse.translatedName.toString(),
                  textAlign: TextAlign.justify,
                  style: robotoMedium.copyWith(
                    fontSize: settings.translateFontSize.value,
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

              // Ayah number and Share button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAyahNumber(context, verse.versesNumber),
                  IconButton(
                    onPressed: () {
                      Share.share(
                        'Arabic Ayah: ${verse.arabicName}\n\nTranslation: ${verse.translatedName}\n\n\nSura Name: ${controller.suraDetaileApiData!.data!.chapter!.translatedName}\nAyah Number: ${verse.versesNumber}\nPowered By: ${AppConstants.APP_NAME}',
                      );
                    },
                    icon: SvgPicture.asset(
                      Images.Icon_Share,
                      height: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAyahNumber(BuildContext context, dynamic verseNumber) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          Images.Icon_End_Ayah,
          height: 45,
          fit: BoxFit.fill,
          color: Theme.of(context).primaryColor,
        ),
        Text(
          verseNumber.toString(), // <- this line must be safe
          style: robotoMedium.copyWith(
            fontSize: Dimensions.FONT_SIZE_SMALL,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
      ],
    );
  }
}
