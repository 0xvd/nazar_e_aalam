// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/category/category_screen.dart';
import 'package:nazar_e_alam/view/screens/compass/compass_screen.dart';
import 'package:nazar_e_alam/view/screens/home/home_screen.dart';
import 'package:nazar_e_alam/view/screens/nearby_mosque/nearby_mosque_screen.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/main_offline_quran_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/sura_list_screen.dart';

import 'np_internet_widgets.dart';

class BottomNavbarScreen extends StatefulWidget {
  const BottomNavbarScreen({super.key});

  @override
  State<BottomNavbarScreen> createState() => _BottomNavbarScreenState();
}

class _BottomNavbarScreenState extends State<BottomNavbarScreen> {
  late List<Widget> _pages;
  int _selectedPageIndex = 0;

  final internetController = Get.put(InternetController());

  // Reference width used as the design baseline (standard mobile width).
  // Adjust this if your designs target a different baseline (e.g. 360).
  static const double _baseWidth = 375;

  @override
  void initState() {
    internetController.checkConnection();
    super.initState();
  }

  void _selectPage(int index) {
    // Prevent access to online-only pages without internet
    if ((index == 3 || index == 4) && !internetController.hasInternet.value) {
      showNoInternetDialog();
      return;
    }
    setState(() => _selectedPageIndex = index);
  }

  /// Scales [baseSize] according to the current device width relative to
  /// [_baseWidth], clamped so text doesn't shrink or grow too aggressively
  /// on very small or very large screens.
  double _responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / _baseWidth;
    final clampedScale = scale.clamp(0.85, 1.25);
    return baseSize * clampedScale;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Platform.isIOS;
    final _ = isDark;

    return Scaffold(
      body: Obx(() {
        _pages = [
          const HomeScreen(),
          const CompassScreen(appBackButton: false),
          internetController.hasInternet.value
              ? const SuraList(appBackButton: false)
              : const MainOfflineQuranScreen(appBackButton: false),
          const NearbyMosque(appBackButton: false),
          CategoryScreen(appBackButton: false),
        ];
        return _pages[_selectedPageIndex];
      }),
      bottomNavigationBar: Obx(() {
        final isModern =
            Get.find<HomeLayoutController>().currentLayout.value ==
            HomeLayoutController.modern;
        return isModern
            ? _buildModernNavBar(context)
            : _buildClassicNavBar(context, isIOS);
      }),
    );
  }

  Widget _buildClassicNavBar(BuildContext context, bool isIOS) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: (isIOS ? 70 : 70),
      decoration: BoxDecoration(
        color: darkMode
            ? Theme.of(context).cardColor
            : Theme.of(context).primaryColor,
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Bottom Navigation Items
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home
                Expanded(
                  child: _buildNavItem(
                    index: 0,
                    icon: Images.Icon_Home,
                    label: "home".tr,
                  ),
                ),
                // Compass
                Expanded(
                  child: _buildNavItem(
                    index: 1,
                    icon: Images.Icon_Qibla,
                    label: "compass".tr,
                  ),
                ),

                // Spacer for FAB
                const SizedBox(width: 56),
                // Nearby Mosque
                Expanded(
                  child: _buildNavItem(
                    index: 3,
                    icon: Images.Icon_near_mosque,
                    label: "nearby".tr,
                  ),
                ),
                // Category
                Expanded(
                  child: _buildNavItem(
                    index: 4,
                    icon: Images.Icon_Category,
                    label: "category".tr,
                  ),
                ),
              ],
            ),
          ),
          _buildQuranFab(
            background: Theme.of(context).scaffoldBackgroundColor,
            bubbleColor: darkMode
                ? Theme.of(context).cardColor.withOpacity(0.8)
                : Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      height: 68,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildModernNavItem(
                  index: 0,
                  icon: Images.ModernIcon_Home,
                  label: "home".tr,
                  tint: false,
                ),
              ),
              Expanded(
                child: _buildModernNavItem(
                  index: 1,
                  icon: Images.ModernIcon_QiblaKaaba,
                  label: "compass".tr,
                  tint: false,
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: _buildModernNavItem(
                  index: 3,
                  icon: Images.Icon_near_mosque,
                  label: "nearby".tr,
                ),
              ),
              Expanded(
                child: _buildModernNavItem(
                  index: 4,
                  icon: Images.Icon_Category,
                  label: "category".tr,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 34,
            child: GestureDetector(
              onTap: () => _selectPage(2),
              child: SizedBox(
                width: 60,
                height: 60,
                child: SvgPicture.asset(Images.ModernIcon_NavCenterRehal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranFab({
    required Color background,
    required Color bubbleColor,
    double bottom = 38,
  }) {
    return Positioned(
      bottom: bottom,
      child: GestureDetector(
        onTap: () => _selectPage(2),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bubbleColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Image.asset(Images.Nav_quran, height: 30)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => _selectPage(index),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              height: 30,
              color: _selectedPageIndex == index
                  ? Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor
                  : Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).primaryColor.withOpacity(0.6)
                  : Theme.of(context).cardColor.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                fontSize: _responsiveFontSize(
                  context,
                  Dimensions.FONT_SIZE_SMALL,
                ),
                height: 1.0,
                color: _selectedPageIndex == index
                    ? Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).hintColor
                    : Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).primaryColor.withOpacity(0.6)
                    : Theme.of(context).cardColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavItem({
    required int index,
    required String icon,
    required String label,
    bool tint = true,
  }) {
    final isActive = _selectedPageIndex == index;
    final color = isActive ? AppColorModern.emerald : Colors.grey;
    return GestureDetector(
      onTap: () => _selectPage(index),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: tint || isActive ? 1 : 0.55,
              child: SvgPicture.asset(
                icon,
                height: 26,
                color: tint ? color : null,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(
                  fontSize: _responsiveFontSize(
                    context,
                    Dimensions.FONT_SIZE_SMALL,
                  ),
                  height: 1.0,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
