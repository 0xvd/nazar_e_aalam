import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/grain_overlay.dart';

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

  bool get _hasBack => isBackButtonExist ?? false;

  void _back(BuildContext context) =>
      onBackPressed != null ? onBackPressed!() : Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return _isClassic
        ? _buildClassicAppBar(context)
        : _buildModernAppBar(context);
  }

  // ───────────── Classic: flat, clean, saffron (card colour in dark) ─────────────
  Widget _buildClassicAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = dark ? theme.cardColor : theme.primaryColor;
    final fg = dark ? const Color(0xFFFFF4E8) : Colors.white;
    final accent = dark ? theme.primaryColor : Colors.white;

    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: accent),
      title: title != null
          ? Text(
              title!.tr,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            )
          : const SizedBox(),
      centerTitle: centerTitle == null ? true : false,
      leading: _hasBack
          ? IconButton(
              splashRadius: 22,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: accent,
              ),
              onPressed: () => _back(context),
            )
          : const SizedBox(),
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
    );
  }

  // ───────────── Modern: clean glass bar, no bubbles, no ugly circles ─────────────
  Widget _buildModernAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [const Color(0xFF1A1A1A), const Color(0xFF2A1A12)]
                      : [const Color(0xFFF26B21), const Color(0xFFF58220)],
                ),
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(child: GrainOverlay(fps: 12)),
            ),
          ],
        ),
      ),
      title: title != null
          ? Text(
              title!.tr,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
            )
          : const SizedBox(),
      centerTitle: centerTitle == null ? true : false,
      leading: _hasBack
          ? Center(
              child: GestureDetector(
                onTap: () => _back(context),
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
    );
  }

  @override
  Size get preferredSize => Size(1170, 56);
}
