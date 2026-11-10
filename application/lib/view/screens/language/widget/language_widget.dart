// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/data/model/response/language_model.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  const LanguageWidget({
    super.key,
    required this.languageModel,
    required this.localizationController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = localizationController.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        localizationController.setLanguage(
          Locale(
            AppConstants.languages[index].languageCode!,
            AppConstants.languages[index].countryCode,
          ),
          index,
        );
        localizationController.setSelectIndex(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.5)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          horizontalTitleGap: Dimensions.PADDING_SIZE_SMALL,
          leading: Image.asset(
            languageModel.imageUrl!,
            width: 25,
            height: 25,
          ),
          title: Text(
            languageModel.languageName!,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 22,
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
