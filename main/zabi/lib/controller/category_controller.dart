import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryListController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getBoolLocally();
  }

// local variable
  RxBool isCategoryChange = false.obs;
  // Method to save boolean value locally
  void saveBoolLocally(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCategoryChangeKey', value);
  }

  // Method to retrieve boolean value locally
  void getBoolLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool newValue = prefs.getBool('isCategoryChangeKey') ?? false;
    isCategoryChange.value = newValue;
    update();
  }
}
