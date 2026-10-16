// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/home_layout_option_card.dart';

/// Settings → Appearance → Home Screen Layout section.
class HomeLayoutDWWidget extends StatelessWidget {
  const HomeLayoutDWWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.all(5),
      title: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: ExpansionTile(
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          expansionAnimationStyle: AnimationStyle(
            duration: const Duration(milliseconds: 500),
          ),
          clipBehavior: Clip.antiAlias,
          title: Row(
            children: [
              Icon(
                Icons.dashboard_customize_outlined,
                size: 25,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
              Text(
                "home_screen_layout_settings".tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.PADDING_SIZE_DEFAULT,
                0,
                Dimensions.PADDING_SIZE_DEFAULT,
                Dimensions.PADDING_SIZE_DEFAULT,
              ),
              child: Obx(() {
                final controller = Get.find<HomeLayoutController>();
                final current = controller.currentLayout.value;

                return Column(
                  children: [
                    HomeLayoutOptionCard(
                      title: 'modern_layout_title'.tr,
                      description: 'modern_layout_desc'.tr,
                      isSelected: current == HomeLayoutController.modern,
                      previewBuilder: (_) => const ModernLayoutPreviewMock(),
                      onTap: () =>
                          controller.setUserLayout(HomeLayoutController.modern),
                    ),
                    HomeLayoutOptionCard(
                      title: 'classic_layout_title'.tr,
                      description: 'classic_layout_desc'.tr,
                      isSelected: current == HomeLayoutController.classic,
                      previewBuilder: (_) => const ClassicLayoutPreviewMock(),
                      onTap: () => controller.setUserLayout(
                        HomeLayoutController.classic,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
