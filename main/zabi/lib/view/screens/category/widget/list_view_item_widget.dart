// ignore_for_file: deprecated_member_use

import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ListViewItemWidget extends StatelessWidget {
  final String itemName;
  final String itemImage;
  final VoidCallback onPressed;
  final double? iconHeight;
  const ListViewItemWidget(
      {super.key,
      required this.itemName,
      required this.itemImage,
      required this.onPressed,
      this.iconHeight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Theme.of(context).cardColor,
        shadowColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
            vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
          ),
          horizontalTitleGap: 5,
          // Dhikr Title English---->
          title: Text(
            itemName,
            style: robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
          ),
          leading: SvgPicture.asset(
            itemImage,
            color: Theme.of(context).primaryColor,
            height: iconHeight ?? 50,
          ),
        ),
      ),
    );
  }
}
