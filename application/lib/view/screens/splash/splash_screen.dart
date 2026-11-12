import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/splash_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _started = false;
  bool _logoReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _start();
  }

  Future<void> _start() async {
    // 1. Decode the logo before we ever show it.
    await precacheImage(const AssetImage(Images.APP_LOGO), context);
    if (!mounted) return;
    setState(() => _logoReady = true);

    // 2. Kick off background work (don't await).
    Get.find<PrayerTimeController>().getLocation();

    // 3. Minimum visible time so the logo doesn't blink away.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // 4. Navigate.
    Get.find<SplashController>().navigator();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _logoReady ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // `Image.asset` hits the same cache `precacheImage` populated,
              // so the first paint of this widget already has the pixels.
              Image.asset(
                Images.APP_LOGO,
                height: 120,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              Text(
                AppConstants.APP_NAME,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.FONT_SIZE_OVER_LARGE,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}