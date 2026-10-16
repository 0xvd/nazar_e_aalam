// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class SettingsItem extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String imagePath;
  final VoidCallback? onTap;
  const SettingsItem({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        shadowColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          horizontalTitleGap: Dimensions.PADDING_SIZE_SMALL,
          leading: SvgPicture.asset(
            imagePath,
            width: 25,
            height: 25,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            title,
            style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
          ),
        ),
      ),
    );
  }
}
