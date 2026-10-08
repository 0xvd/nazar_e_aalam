// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_milestone_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/tabbar_button.dart';
import 'package:nazar_e_alam/view/screens/quran/quran_settings_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/arabic_quran_widget.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/ayah_translation_widget.dart';

class SuraDetaileScreen extends StatelessWidget {
  final bool appBackButton;
  final int? savedPage = int.tryParse(Get.arguments.toString());

  SuraDetaileScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranController>(
      builder: (quranController) {
        final isLoading = quranController.isSuraDetaileLoading.value;
        final sura = quranController.suraDetaileApiData?.data?.chapter;

        if (!isLoading && sura?.id != null) {
          final suraId = sura!.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<QuranMilestoneController>().markSurahRead(suraId);
          });
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: isLoading
                ? "--"
                : "${sura?.translatedName}\n${sura?.versesTranslateName}: ${sura?.versesCount}",
            isBackButtonExist: appBackButton,
            actions: [
              if (!isLoading)
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
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    children: [
                      Center(child: ArabicQuranWidget(pageNumber: savedPage)),
                      const Center(child: AyanTranslationWidget()),
                    ],
                  ),
                ),
                _buildNavigationButtons(context, quranController),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
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
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
      ),
      tabs: [
        tabBarButton('arabic'.tr, context),
        tabBarButton('ayah_and_translation'.tr, context),
      ],
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, QuranController quranController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      child: Row(
        children: [
          _navButton(
            context,
            icon: Icons.chevron_left,
            label: 'previous_sura'.tr,
            isEnabled: quranController.suraNumber != 1,
            onPressed: () {
              quranController.suraNumber =
                  (quranController.suraNumber ?? 1) - 1;
              quranController.fetchSuraDetaileData(
                suraId: quranController.suraNumber.toString(),
              );
              Get.toNamed(RouteHelper.suraDetaile, arguments: 0);
            },
          ),
          const SizedBox(width: 16),
          _navButton(
            context,
            label: 'next_sura'.tr,
            icon: Icons.chevron_right,
            isLeftIcon: false,
            isEnabled: quranController.suraNumber != 114,
            onPressed: () {
              quranController.suraNumber =
                  (quranController.suraNumber ?? 1) + 1;
              quranController.fetchSuraDetaileData(
                suraId: quranController.suraNumber.toString(),
              );
              Get.toNamed(RouteHelper.suraDetaile, arguments: 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    bool isLeftIcon = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isLeftIcon
                  ? [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(label, style: robotoMedium.copyWith(fontSize: 15)),
                    ]
                  : [
                      Text(label, style: robotoMedium.copyWith(fontSize: 15)),
                      const SizedBox(width: 8),
                      Icon(icon, size: 20),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
