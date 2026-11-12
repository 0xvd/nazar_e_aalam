import 'package:get/get.dart';
import 'package:nazar_e_alam/data/repository/splash_repo.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;

  SplashController({required this.splashRepo});

  // Navigate immediately. Timing is owned by SplashScreen, not this controller.
  void navigator() {
    if (isClosed) return;
    Get.offAllNamed(RouteHelper.bottomNavbar);
  }
}