// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/offline_quran_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/offline_surah_detail_screen.dart';
import '../../../../controller/quran_settings_controller.dart';
import '../../../base/loading_indicator.dart';

class OfflineSuraList extends StatelessWidget {
  const OfflineSuraList({super.key});

  @override
  Widget build(BuildContext context) {
    final OfflineQuranController offlineQuranController = Get.put(
      OfflineQuranController(),
    );

    // Load the offline surah list once
    offlineQuranController.loadSurahList();

    return Obx(() {
      final surahs = offlineQuranController.surahList;

      if (offlineQuranController.isLoading.value || surahs.isEmpty) {
        return const Center(child: LoadingIndicator());
      }

      return ListView.builder(
        primary: false,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_SMALL,
        ),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final sura = surahs[index];

          return GestureDetector(
            onTap: () {
              offlineQuranController.lastSurahNumber = sura.id;
              Get.to(
                () => OfflineSuraDetaileScreen(
                  appBackButton: true,
                  surahNumber: sura.id.toString(),
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
                contentPadding: const EdgeInsetsDirectional.only(
                  start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  end: Dimensions.PADDING_SIZE_SMALL,
                ),
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      Images.Icon_Star,
                      height: 50,
                      fit: BoxFit.fill,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      sura.id.toString(),
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_SMALL,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
                title: Obx(
                  () => Text(
                    sura.translateName,
                    style: robotoMedium.copyWith(
                      fontSize: Get.find<SettingsController>()
                          .translateFontSize
                          .value,
                    ),
                  ),
                ),
                subtitle: Obx(
                  () => Text(
                    "Verses: ${sura.versesCount}",
                    style: robotoMedium.copyWith(
                      fontSize:
                          Get.find<SettingsController>()
                              .translateFontSize
                              .value -
                          3,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
                trailing: Obx(
                  () => Text(
                    sura.arabicName,
                    style: Get.find<SettingsController>()
                        .selectedArabicFont
                        .copyWith(
                          fontSize: Get.find<SettingsController>()
                              .arabicFontSize
                              .value,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
