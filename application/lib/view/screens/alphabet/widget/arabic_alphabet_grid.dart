import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

import '../../../../controller/alphabet_controller.dart';

class ArabicAlphabetGrid extends StatelessWidget {
  const ArabicAlphabetGrid({super.key});

  static Decoration _tileGradient() {
    final theme = Theme.of(Get.context!);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: Get.isDarkMode
            ? [theme.primaryColor, theme.primaryColor]
            : [theme.primaryColor, theme.primaryColor],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AlphabetController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double maxTileExtent = 120;
            final crossAxisCount = (constraints.maxWidth / maxTileExtent)
                .clamp(2, 8)
                .floor();

            return GridView.builder(
              itemCount: controller.letters.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final letter = controller.letters[index];
                return _ArabicTile(
                  text: letter,
                  onTap: () {
                    Vibration.vibrate(duration: 50);
                    controller.speak(letter);
                  },
                  background: _tileGradient(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ArabicTile extends StatefulWidget {
  const _ArabicTile({
    required this.text,
    required this.onTap,
    required this.background,
  });

  final String text;
  final VoidCallback onTap;
  final Decoration background;

  @override
  State<_ArabicTile> createState() => _ArabicTileState();
}

class _ArabicTileState extends State<_ArabicTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => Future.delayed(const Duration(milliseconds: 90), () {
            if (mounted) setState(() => _pressed = false);
          }),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
          child: Ink(
            // decoration: widget.background,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // SVG Background
                Positioned.fill(
                  child: SvgPicture.asset(
                  Get.isDarkMode ? Images.Dark_Alphabet_Frame :  Images.Alphabet_Frame,
                    fit: BoxFit.cover,
                  ),
                ),
                // Text on top
                Center(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: robotoBlack.copyWith(
                      color: Get.isDarkMode
                          ? AppColor.cardColor
                          : Theme.of(context).textTheme.bodyLarge!.color,
                      fontSize:
                          Dimensions.FONT_SIZE_OVER_LARGE +
                          Dimensions.FONT_SIZE_EXTRA_LARGE,
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
