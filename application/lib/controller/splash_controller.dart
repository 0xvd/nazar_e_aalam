import 'dart:async';

import 'package:get/get.dart';
import 'package:nazar_e_alam/data/repository/splash_repo.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;

  SplashController({required this.splashRepo});

  Timer? _navigationTimer;

  // Navigate from splash to the bottom navbar screen.
  void navigator() {
    _navigationTimer?.cancel();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        Get.offAllNamed(RouteHelper.bottomNavbar);
      }
    });
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    _navigationTimer = null;
    super.onClose();
  }
}
