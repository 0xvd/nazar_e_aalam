// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/compass/compass_screen.dart';
import 'package:nazar_e_alam/view/screens/home/home_screen.dart';
import 'package:nazar_e_alam/view/screens/nearby_mosque/nearby_mosque_screen.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/main_offline_quran_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/sura_list_screen.dart';
import 'package:nazar_e_alam/view/screens/settings/settings_screen.dart';

import 'np_internet_widgets.dart';

class BottomNavbarScreen extends StatefulWidget {
  const BottomNavbarScreen({super.key});

  @override
  State<BottomNavbarScreen> createState() => _BottomNavbarScreenState();
}

class _BottomNavbarScreenState extends State<BottomNavbarScreen> {
  int _selectedPageIndex = 0;

  final internetController = Get.put(InternetController());

  static const double _baseWidth = 375;
  static const double _barHeight = 68;
  static const double _fabSize = 58;
  // Total height of the nav area (bar + the part of the FAB above the bar).
  static const double _navAreaHeight = 86;

  @override
  void initState() {
    internetController.checkConnection();
    super.initState();
  }

  void _selectPage(int index) {
    // Nearby mosque is online-only (Settings works offline)
    if (index == 3 && !internetController.hasInternet.value) {
      showNoInternetDialog();
      return;
    }
    setState(() => _selectedPageIndex = index);
  }

  double _responsiveFontSize(BuildContext context, double baseSize) {
    final scale = (MediaQuery.of(context).size.width / _baseWidth)
        .clamp(0.85, 1.25);
    return baseSize * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isModern = Get.find<HomeLayoutController>().currentLayout.value ==
          HomeLayoutController.modern;

      final pages = <Widget>[
        const HomeScreen(),
        const CompassScreen(appBackButton: false),
        internetController.hasInternet.value
            ? const SuraList(appBackButton: false)
            : const MainOfflineQuranScreen(appBackButton: false),
        const NearbyMosque(appBackButton: false),
        const SettingsScreen(appBackButton: false),
      ];

      return Scaffold(
        // Modern: content scrolls behind the floating glass bar.
        // NOTE: scrollable screens should add ~100px bottom padding in modern.
        extendBody: isModern,
        body: pages[_selectedPageIndex],
        bottomNavigationBar:
            isModern ? _buildModernNavBar(context) : _buildClassicNavBar(context),
      );
    });
  }

  // ───────────────────────── CLASSIC ─────────────────────────

  Widget _buildClassicNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final barColor = dark ? theme.cardColor : Colors.white;

    return SizedBox(
      height: _navAreaHeight + MediaQuery.of(context).padding.bottom,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: _barHeight + MediaQuery.of(context).padding.bottom,
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(26)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.4 : 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: _buildItemsRow(context, glass: false),
          ),
          Positioned(
            top: 0,
            child: _buildQuranFab(
              ringColor: theme.scaffoldBackgroundColor,
              glow: false,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── MODERN (glass) ─────────────────────────

  Widget _buildModernNavBar(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = dark ? const Color(0x33FFFFFF) : const Color(0x80FFFFFF);
    final border = dark ? const Color(0x40FFFFFF) : const Color(0xB3FFFFFF);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SizedBox(
          height: _navAreaHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Glass bar
              Container(
                height: _barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.45 : 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: border, width: 1.2),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(dark ? 0.18 : 0.55),
                            Colors.white.withOpacity(dark ? 0.06 : 0.25),
                          ],
                        ),
                      ),
                      child: _buildItemsRow(context, glass: true),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: _buildQuranFab(
                  ringColor: Colors.white.withOpacity(dark ? 0.12 : 0.55),
                  glow: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── SHARED PIECES ─────────────────────────

  Widget _buildItemsRow(BuildContext context, {required bool glass}) {
    return Row(
      children: [
        Expanded(
          child: _buildNavItem(
            context,
            index: 0,
            icon: glass ? Images.ModernIcon_Home : Images.Icon_Home,
            label: 'home'.tr,
            tint: !glass,
          ),
        ),
        Expanded(
          child: _buildNavItem(
            context,
            index: 1,
            icon: glass ? Images.ModernIcon_QiblaKaaba : Images.Icon_Qibla,
            label: 'compass'.tr,
            tint: !glass,
          ),
        ),
        const SizedBox(width: _fabSize + 14), // space for the raised button
        Expanded(
          child: _buildNavItem(
            context,
            index: 3,
            icon: Images.Icon_near_mosque,
            label: 'nearby'.tr,
          ),
        ),
        Expanded(
          child: _buildNavItem(
            context,
            index: 4,
            icon: Images.Icon_app_setting,
            label: 'settings'.tr,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String icon,
    required String label,
    bool tint = true,
  }) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final active = _selectedPageIndex == index;

    final inactive = dark ? const Color(0xFFC9B8A6) : const Color(0xFF8A7B6D);
    final color = active ? AppColor.primaryColor : inactive;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectPage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: active
                  ? AppColor.primaryColor.withOpacity(dark ? 0.22 : 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Opacity(
              opacity: tint || active ? 1 : 0.6,
              child: SvgPicture.asset(
                icon,
                height: 24,
                colorFilter:
                    tint ? ColorFilter.mode(color, BlendMode.srcIn) : null,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: robotoMedium.copyWith(
              fontSize:
                  _responsiveFontSize(context, Dimensions.FONT_SIZE_SMALL - 1),
              height: 1.0,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranFab({required Color ringColor, required bool glow}) {
    return GestureDetector(
      onTap: () => _selectPage(2),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, color: ringColor),
        child: Container(
          width: _fabSize,
          height: _fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A4C), Color(0xFFF26B21)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF26B21).withOpacity(glow ? 0.55 : 0.35),
                blurRadius: glow ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              Images.Nav_quran,
              height: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}