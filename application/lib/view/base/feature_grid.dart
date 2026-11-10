import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/feature_items.dart';

/// Flat grid of feature cards — no sections, no Worship/Tools/More headers.
/// Drop it into any scroll view:
///   FeatureGrid(modern: true, bottomPadding: 100)
/// Do NOT wrap it in another scrollable; it sizes itself.
class FeatureGrid extends StatelessWidget {
  final bool modern;
  final double bottomPadding;
  final EdgeInsetsGeometry padding;
  const FeatureGrid({
    super.key,
    this.modern = false,
    this.bottomPadding = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  static const double _cardHeight = 116;
  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final items = FeatureItems.all();
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: _gap,
              mainAxisSpacing: _gap,
              mainAxisExtent: _cardHeight,
            ),
            children: [
              for (final item in items)
                FeatureCard(item: item, modern: modern),
            ],
          ),
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final FeatureItem item;
  final bool modern;
  const FeatureCard({super.key, required this.item, this.modern = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final radius = BorderRadius.circular(modern ? 22 : 18);

    final border = dark ? const Color(0xFF3A2E24) : const Color(0xFFF0E4D3);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: theme.cardColor,
        border: Border.all(
          color: modern ? primary.withValues(alpha: 0.18) : border,
        ),
        gradient: modern
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF2B1D13), theme.cardColor]
                    : [Colors.white, const Color(0xFFFFF1E4)],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: () => Get.toNamed(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: dark ? 0.20 : 0.12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      item.icon,
                      height: 28,
                      width: 28,
                      colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    item.titleKey.tr,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(
                      fontSize: 12.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
