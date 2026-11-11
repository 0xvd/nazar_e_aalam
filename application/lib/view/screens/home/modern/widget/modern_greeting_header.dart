// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/grain_overlay.dart';

/// Modern header: deep, rich brand gradient (no pale/white corner) with a
/// heavy static grain for a premium matte look.
class ModernGreetingHeader extends StatelessWidget {
  final dynamic mosqueData;
  const ModernGreetingHeader({super.key, required this.mosqueData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final prayer = Get.find<PrayerTimeController>();

    // Every stop is a saturated colour, so nothing reads as a white shade.
    final gradient = dark
        ? const [Color(0xFF3A2112), Color(0xFF241810), Color(0xFF16100B)]
        : [
            const Color(0xFFF26B21),
            const Color(0xFFE0561A),
            Color.lerp(primary, const Color(0xFFE8202A), 0.55)!,
          ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Fine, moving film grain.
            Positioned.fill(
              child: GrainOverlay(
                density: dark ? 0.45 : 0.42,
                opacity: dark ? 0.16 : 0.20,
                fps: 9,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 14,
                20,
                26,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nazar e Aalam',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            fontSize: 24,
                            letterSpacing: 0.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _GlassButton(
                        icon: dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        tooltip: 'light_or_dark_mode'.tr,
                        onTap: () => Get.find<ThemeController>().toggleTheme(),
                      ),
                      const SizedBox(width: 10),
                      _GlassButton(
                        icon: Icons.settings_outlined,
                        tooltip: 'settings'.tr,
                        onTap: () => Get.toNamed(RouteHelper.settings),
                      ),
                    ],
                  ),
                  // Location
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  prayer.saveLocalStoreCity ??
                                      prayer.currentAddress.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoMedium.copyWith(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}