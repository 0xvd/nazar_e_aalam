// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
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
  static const double _barHeight = 70;
  static const double _fabSize = 60;
  static const double _navAreaHeight = 90;

  // Classic notch: the round cut in the middle of the bar.
  // FAB centre sits 15px below the bar top (see _navAreaHeight - _barHeight).

  @override
  void initState() {
    internetController.checkConnection();
    super.initState();
  }

  void _selectPage(int index) {
    if (index == 3 && !internetController.hasInternet.value) {
      showNoInternetDialog();
      return;
    }
    setState(() => _selectedPageIndex = index);
  }

  double _responsiveFontSize(BuildContext context, double baseSize) {
    final scale = (MediaQuery.of(context).size.width / _baseWidth).clamp(
      0.85,
      1.25,
    );
    return baseSize * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isModern =
          Get.find<HomeLayoutController>().currentLayout.value ==
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
        extendBody: isModern,
        body: pages[_selectedPageIndex],
        bottomNavigationBar: isModern
            ? _buildModernNavBar(context)
            : _buildClassicNavBar(context),
      );
    });
  }

  Widget _buildClassicNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final barColor = dark ? theme.cardColor : Colors.white;
    final primary = theme.primaryColor;
    return SizedBox(
      height: _navAreaHeight + MediaQuery.of(context).padding.bottom,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: _barHeight + MediaQuery.of(context).padding.bottom,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.4 : 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: _buildItemsRow(context, glass: false, primary: primary),
          ),
          Positioned(
            top: 0,
            child: _buildQuranFab(
              ringColor: theme.scaffoldBackgroundColor,
              glow: false,
              primary: primary,
            ),
          ),
        ],
      ),
    );
  }
  // ───────────────────────── MODERN (glass) ─────────────────────────

  Widget _buildModernNavBar(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    final fill = dark ? const Color(0x2AFFFFFF) : const Color(0x6AFFFFFF);
    final border = dark ? const Color(0x55FFFFFF) : const Color(0x99FFFFFF);
    final saffronGlow = dark
        ? primary.withOpacity(0.35)
        : primary.withOpacity(0.50);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: SizedBox(
          height: _navAreaHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: _barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.50 : 0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: saffronGlow.withOpacity(dark ? 0.18 : 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        color: fill,
                        border: Border.all(color: border, width: 1.5),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(dark ? 0.22 : 0.45),
                            Colors.white.withOpacity(dark ? 0.04 : 0.15),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(dark ? 0.12 : 0.30),
                            blurRadius: 0,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: _buildItemsRow(
                        context,
                        glass: true,
                        primary: primary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -6,
                child: _buildQuranFab(
                  ringColor: dark
                      ? Colors.white.withOpacity(0.14)
                      : Colors.white.withOpacity(0.60),
                  glow: true,
                  primary: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── SHARED PIECES ─────────────────────────

  Widget _buildItemsRow(
    BuildContext context, {
    required bool glass,
    required Color primary,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildNavItem(
            context,
            index: 0,
            icon: glass ? Images.ModernIcon_Home : Images.Icon_Home,
            label: 'home'.tr,
            tint: !glass,
            primary: primary,
          ),
        ),
        Expanded(
          child: _buildNavItem(
            context,
            index: 1,
            icon: glass ? Images.ModernIcon_QiblaKaaba : Images.Icon_Qibla,
            label: 'compass'.tr,
            tint: !glass,
            primary: primary,
          ),
        ),
        const SizedBox(width: _fabSize + 14),
        Expanded(
          child: _buildNavItem(
            context,
            index: 3,
            icon: Images.Icon_near_mosque,
            label: 'nearby'.tr,
            primary: primary,
          ),
        ),
        Expanded(
          child: _buildNavItem(
            context,
            index: 4,
            icon: Images.Icon_app_setting,
            label: 'settings'.tr,
            primary: primary,
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
    required Color primary,
  }) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final active = _selectedPageIndex == index;

    final inactive = dark ? const Color(0xFFC9B8A6) : const Color(0xFF8A7B6D);
    final color = active ? primary : inactive;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectPage(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The pill grows when selected; the icon lifts and pops.
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: active ? 16 : 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: active
                  ? primary.withOpacity(dark ? 0.20 : 0.16)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              offset: active ? const Offset(0, -0.08) : Offset.zero,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutBack,
                scale: active ? 1.18 : 1.0,
                child: Opacity(
                  opacity: tint || active ? 1 : 0.55,
                  child: SvgPicture.asset(
                    icon,
                    height: 24,
                    width: 24,
                    colorFilter: tint
                        ? ColorFilter.mode(color, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: robotoMedium.copyWith(
              fontSize: _responsiveFontSize(
                context,
                Dimensions.FONT_SIZE_SMALL - 1,
              ),
              height: 1.0,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranFab({
    required Color ringColor,
    required bool glow,
    required Color primary,
  }) {
    return GestureDetector(
      onTap: () => _selectPage(2),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        scale: 1.0,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor,
            border: glow
                ? Border.all(color: primary.withOpacity(0.25), width: 1)
                : null,
          ),
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
                  color: const Color(
                    0xFFF26B21,
                  ).withOpacity(glow ? 0.50 : 0.30),
                  blurRadius: glow ? 24 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                Images.Nav_quran,
                height: 30,
                // color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
