import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/images.dart';

import '../../../../controller/localization_controller.dart';
import '../../../../data/model/response/language_model.dart';
import '../../../../util/app_constants.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  const LanguageWidget(
      {super.key,
      required this.languageModel,
      required this.localizationController,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        localizationController.setLanguage(
            Locale(
              AppConstants.languages[index].languageCode!,
              AppConstants.languages[index].countryCode,
            ),
            index);
        localizationController.setSelectIndex(index);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        shadowColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        ),
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: Dimensions.PADDING_SIZE_SMALL,
          ),
          horizontalTitleGap: Dimensions.PADDING_SIZE_SMALL,
          leading: Image.asset(
            languageModel.imageUrl!.toString(),
            width: 25,
            height: 25,
          ),
          title: Text(languageModel.languageName!, style: robotoMedium),
          trailing: localizationController.selectedIndex == index
              ? Image.asset(
                  Get.isDarkMode
                      ? Images.Icon_select_lan_dark
                      : Images.Icon_select_lan_light,
                  width: 25,
                  height: 25,
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
