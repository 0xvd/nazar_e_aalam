// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/language/widget/language_widget.dart';

class LanguageDWWidget extends StatelessWidget {
  const LanguageDWWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizationController) {
        return ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.all(5),
          title: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ExpansionTile(
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              expansionAnimationStyle: AnimationStyle(
                duration: const Duration(milliseconds: 500),
              ),
              clipBehavior: Clip.antiAlias,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        Images.Icon_select_language,
                        width: 25,
                        height: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                      Text(
                        "language_settings".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: localizationController.languages.length,
                  itemBuilder: (context, index) => LanguageWidget(
                    languageModel: localizationController.languages[index],
                    localizationController: localizationController,
                    index: index,
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
