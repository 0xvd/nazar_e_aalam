// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/bookmark_controller.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/tabbar_button.dart';
import 'package:nazar_e_alam/view/screens/quran/quran_settings_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/bookmark_tab.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/juz_list_widget.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/sura_list_widget.dart';

class SuraList extends StatelessWidget {
  final bool appBackButton;
  const SuraList({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController(quranSettingRepo: Get.find()));

    final BookMarkController bookMarkController = Get.put(BookMarkController());
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: "holy_quran".tr,
        isBackButtonExist: appBackButton == true ? true : false,
        actions: [
          IconButton(
            onPressed: () {
              openBottomSheet(context);
            },
            icon: SvgPicture.asset(
              Images.Icon_Quran_Setting,
              color: Get.isDarkMode
                  ? Theme.of(context).textTheme.bodyMedium!.color
                  : Theme.of(context).cardColor,
              height: 28,
            ),
          ),
        ],
      ),

      // body start==>
      body: GetBuilder<QuranController>(
        builder: (quranController) {
          return DefaultTabController(
            initialIndex: bookMarkController.bookMarks.isEmpty ? 0 : 2,
            length: 3,
            child: Column(
              children: [
                // tab bar start
                TabBar(
                  dividerColor: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                    vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  isScrollable: false,
                  indicator: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  ),
                  // all tabs name
                  tabs: [
                    tabBarButton('surah_list'.tr, context),
                    tabBarButton('juz_list'.tr, context),
                    tabBarButton('bookmark'.tr, context),
                  ],
                ),
                // tabbar view==>
                Expanded(
                  child: TabBarView(
                    children: [
                      const Center(child: SuraListWidget()),
                      const Center(child: JuzListWidget()),
                      BookmarkTab()
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
