// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../util/dimensions.dart';
import '../../../../../util/styles.dart';

class FeatureItemWidget extends StatelessWidget {
  final String itemName;
  final String itemIconPath;
  final VoidCallback onPressed;
  const FeatureItemWidget({
    required this.itemName,
    required this.itemIconPath,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).hintColor.withOpacity(0.2),
              Theme.of(context).hintColor.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // item icon path
            SvgPicture.asset(
              itemIconPath,
              color: Theme.of(context).primaryColor,
              height: 40,
            ), //  item name
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_EXTRA_GRID_SMALL - 2,
              ),
              child: Text(
                itemName,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_SMALL,
                  color: Get.isDarkMode
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
