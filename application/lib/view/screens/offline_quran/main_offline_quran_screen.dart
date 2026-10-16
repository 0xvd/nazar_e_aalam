// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/tabbar_button.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/offline_juzz_list.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/widgets/offline_sura_list.dart';
import 'package:nazar_e_alam/view/screens/quran/quran_settings_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/bookmark_tab.dart';

class MainOfflineQuranScreen extends StatefulWidget {
  final bool appBackButton;
  const MainOfflineQuranScreen({super.key, required this.appBackButton});

  @override
  State<MainOfflineQuranScreen> createState() => _MainOfflineQuranScreenState();
}

class _MainOfflineQuranScreenState extends State<MainOfflineQuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: "holy_quran".tr,
        // title: "Offline Quran".tr,
        isBackButtonExist: widget.appBackButton == true ? true : false,
        actions: [
          // Quran Setting
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
      // body start ==>
      body: Column(
        children: [
          // tab bar start
          TabBar(
            controller: _tabController,
            dividerColor: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_DEFAULT,
              vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
            ),
            labelPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
            ),
            isScrollable: false,
            indicator: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            ),
            // all tabs name
            tabs: [
              tabBarButton('surah_list'.tr, context),
              tabBarButton('juz_list'.tr, context),
              tabBarButton('bookmark'.tr, context),
            ],
          ),

          // tabbar view ==>
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const OfflineSuraList(),
                const OfflineJuzListWidget(),
                BookmarkTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
