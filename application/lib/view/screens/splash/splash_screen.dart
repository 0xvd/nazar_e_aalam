import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/splash_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
// import 'package:path/path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // _checkNotificationPermission();

    // Run these once when the splash screen is initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Get.find<PrayerTimeController>().getLocation();
      Get.find<SplashController>().navigator();
    });
  }

  // Future<void> _checkNotificationPermission() async {
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     var status = await Permission.notification.status;
  //     if (!status.isGranted) {
  //       await Permission.notification.request();
  //     }
  //   }

  // }

  @override
  Widget build(BuildContext context) {
    // Get.find<PrayerTimeController>().getLocation();
    // Get.find<SplashController>().navigator();
    debugPrint('Splash Screen App logo Path ${Images.APP_LOGO}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // logo image
            Image.asset(
              Images.APP_LOGO,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

            // app name
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
    );
  }
}
