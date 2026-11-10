import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  final double buttonWidth;
  final String buttonName;
  final double? fontSize;
  final Color? disableColor; // when set, a solid colour replaces the gradient
  final Widget? buttonLoderWidget;
  final VoidCallback onPressed;
  const CustomButton({
    super.key,
    required this.buttonWidth,
    required this.buttonName,
    this.fontSize,
    required this.onPressed,
    this.disableColor,
    this.buttonLoderWidget,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final radius = BorderRadius.circular(16);

    return SizedBox(
      width: buttonWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: disableColor,
          gradient: disableColor == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFFF8A4C), primary],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (disableColor ?? primary).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
              child: Center(
                child: buttonLoderWidget ??
                    Text(
                      buttonName.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize ?? 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}