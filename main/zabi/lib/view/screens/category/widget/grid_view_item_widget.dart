// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';

class GridViewItemWidget extends StatelessWidget {
  final String itemName;
  final String itemImage;
  final Color? imageBgColor;
  final double? iconHeight;
  final VoidCallback onPressed;

  const GridViewItemWidget({
    super.key,
    required this.onPressed,
    required this.itemName,
    required this.itemImage,
    this.imageBgColor,
    this.iconHeight,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_GRID_SMALL),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
          boxShadow: [
            BoxShadow(
                color: Get.isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
                spreadRadius: 1,
                blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // item icon ==>
            SvgPicture.asset(
              itemImage,
              color:
                  imageBgColor == null ? Theme.of(context).primaryColor : null,
              height: iconHeight ?? 50,
            ),
            const SizedBox(height: 5),
            // item name ===>
            Text(
              itemName,
              textAlign: TextAlign.center,
              style:
                  robotoMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE),
            ),
          ],
        ),
      ),
    );
  }
}
