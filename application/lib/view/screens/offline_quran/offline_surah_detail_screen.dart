// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/offline_quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_milestone_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/tabbar_button.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/widgets/offline_arabic_quran.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/widgets/offline_ayah_translation_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/quran_settings_screen.dart';

class OfflineSuraDetaileScreen extends StatefulWidget {
  final bool appBackButton;
  final String surahNumber;

  const OfflineSuraDetaileScreen({
    super.key,
    required this.appBackButton,
    required this.surahNumber,
  });

  @override
  State<OfflineSuraDetaileScreen> createState() =>
      _OfflineSuraDetaileScreenState();
}

class _OfflineSuraDetaileScreenState extends State<OfflineSuraDetaileScreen> {
  final OfflineQuranController offlineQuranController = Get.put(
    OfflineQuranController(),
  );

  @override
  void initState() {
    super.initState();

    /// ✅ Load only once when screen opens (not during every rebuild)
    Future.microtask(() {
      final surahNumber = int.parse(widget.surahNumber);
      offlineQuranController.loadSurahDetails(surahNumber: surahNumber);
      Get.find<QuranMilestoneController>().markSurahRead(surahNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    int savedPage = 0;
    int initialTabIndex = 0;
    String highlightedWord = "";

    if (Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      savedPage = args['pageNumber'] ?? 0;
      initialTabIndex = args['initialTabIndex'] ?? 0;
      highlightedWord = args['highlightedWord'] ?? "";
    } else if (Get.arguments is int) {
      savedPage = Get.arguments as int;
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GetBuilder<OfflineQuranController>(
          builder: (controller) {
            final title =
                controller.suraDetailsApiData?.data?.chapter?.translatedName ??
                controller.suraDetailsApiData?.data?.chapter?.arabicName ??
                'holy_quran'.tr;

            return CustomAppBar(
              title: title,
              isBackButtonExist: widget.appBackButton,
              actions: [
                IconButton(
                  onPressed: () => openBottomSheet(context),
                  icon: SvgPicture.asset(
                    Images.Icon_Quran_Setting,
                    color: Get.isDarkMode
                        ? Theme.of(context).indicatorColor
                        : Theme.of(context).cardColor,
                    height: 28,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: DefaultTabController(
        length: 2,
        initialIndex: initialTabIndex,
        child: Column(
          children: [
            TabBar(
              dividerColor: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
              ),
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              ),
              tabs: [
                tabBarButton('arabic'.tr, context),
                tabBarButton('ayah_and_translation'.tr, context),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  OfflineArabicQuranAutoDetectScreen(
                    pageNumber: savedPage,
                    highlightedWord: highlightedWord,
                  ),
                  const OfflineAyanTranslationWidget(),
                ],
              ),
            ),
            GetBuilder<OfflineQuranController>(
              builder: (controller) {
                final currentSurah = controller.lastSurahNumber ?? 1;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: currentSurah > 1
                          ? () => controller.changeSurah(currentSurah - 1)
                          : null,
                      child: Text('previous_sura'.tr, style: robotoBlack),
                    ),
                    TextButton(
                      onPressed: currentSurah < 114
                          ? () => controller.changeSurah(currentSurah + 1)
                          : null,
                      child: Text('next_sura'.tr, style: robotoBlack),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          ],
        ),
      ),
    );
  }
}
