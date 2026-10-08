import 'package:get/get.dart';
import 'package:nazar_e_alam/data/repository/splash_repo.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});
  // navigate splash to navbar screen function
  Future<void> navigator() async {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(RouteHelper.bottomNavbar);
    });
  }
}
