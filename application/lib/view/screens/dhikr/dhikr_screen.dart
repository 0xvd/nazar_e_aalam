import 'package:nazar_e_alam/controller/dhikr_controller.dart';
import 'package:nazar_e_alam/data/repository/dikir_list_repo.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/tabbar_button.dart';
import 'package:nazar_e_alam/view/screens/dhikr/api%20dhikr/api_dikir_widget.dart';
import 'package:nazar_e_alam/view/screens/dhikr/local%20stroge%20dhikr/user_added_dikir_list_widget.dart';

class DhikrScreen extends StatefulWidget {
  final bool appBackButton;
  const DhikrScreen({super.key, required this.appBackButton});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  @override
  void initState() {
    Get.put(DhikrRepo(
      apiClient: Get.find(),
      sharedPreferences: Get.find(),
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Get.find<DhikrController>().fetchDikirListData();
    return GetBuilder<DhikrController>(
      builder: (dikirListController) {
        return Scaffold(
          // Appbar start ===>
          appBar: CustomAppBar(
            title: "all_dhikr".tr,
            isBackButtonExist: widget.appBackButton == true ? true : false,
            actions: [
              IconButton(
                tooltip: "add_dikir".tr,
                onPressed: () {
                  Get.toNamed(RouteHelper.addDhikr);
                },
                icon: Icon(
                  Icons.playlist_add,
                  color: Get.isDarkMode
                      ? Theme.of(context).textTheme.bodyMedium!.color
                      : Theme.of(context).cardColor,
                ),
              ),
            ],
          ),

          // body statr ==>
          body: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // tabbar start
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
                  tabs: [
                    tabBarButton('dhikr'.tr, context),
                    tabBarButton('added_dhikr'.tr, context),
                  ],
                ),
                // tabbar view
                Expanded(
                  child: TabBarView(
                    children: [
                      // api dhikr list
                      const ApiDikirWidget(),

                      // local stroge dhikr list
                      UserAddedDikirWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
