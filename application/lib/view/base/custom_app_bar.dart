// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isBackButtonExist;
  final Function? onBackPressed;
  final List<Widget>? actions;
  final bool? centerTitle;
  const CustomAppBar({
    super.key,
    this.actions,
    this.title,
    this.isBackButtonExist,
    this.onBackPressed,
    this.centerTitle,
  });

  bool get _isClassic =>
      Get.find<HomeLayoutController>().currentLayout.value ==
      HomeLayoutController.classic;

  @override
  Widget build(BuildContext context) {
    return _isClassic
        ? _buildClassicAppBar(context)
        : _buildModernAppBar(context);
  }

  // ---- Classic: your original flat appbar, unchanged ----
  Widget _buildClassicAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Get.isDarkMode
          ? Theme.of(context).cardColor
          : Theme.of(context).primaryColor,          
      title: title != null
          ? Text(
              title!.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                color: Get.isDarkMode
                  ? Theme.of(context).cardColor
                  : Theme.of(context).primaryColor,          
              ),
            )
          : const SizedBox(),
      centerTitle: centerTitle == null ? true : false,
      leading: isBackButtonExist!
          ? GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyMedium!.color
                    : Theme.of(context).cardColor,
              ),
              onTap: () => onBackPressed != null
                  ? onBackPressed!()
                  : Navigator.pop(context),
            )
          : const SizedBox(),
      actions: actions,
      elevation: 0,
    );
  }

  // ---- Modern: glassy depth, pill back button, refined typography ----
  Widget _buildModernAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    final Color base = theme.primaryColor;
    final Color surface = isDark
        ? theme.cardColor
        : theme.scaffoldBackgroundColor;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    base.withValues(alpha: 0.95),
                    base.withValues(alpha: 0.65),
                    surface,
                  ]
                : [base, Color.lerp(base, Colors.black, 0.18)!],
            stops: isDark ? const [0.0, 0.55, 1.0] : const [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // subtle decorative circle for depth, clipped to the rounded shape
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // thin accent line at the very bottom for a crisp finish
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      title: title != null
          ? Text(
              title!.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
            )
          : const SizedBox(),
      centerTitle: centerTitle == null ? true : false,
      leading: isBackButtonExist!
          ? Center(
              child: GestureDetector(
                onTap: () => onBackPressed != null
                    ? onBackPressed!()
                    : Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : const SizedBox(),
      actions: actions
          ?.map(
            (a) => Padding(padding: const EdgeInsets.only(right: 6), child: a),
          )
          .toList(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}
