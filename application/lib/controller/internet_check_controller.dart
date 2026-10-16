import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class InternetController extends GetxController {
  // Reactive variable to track internet state
  var hasInternet = true.obs;

  late final Connectivity _connectivity;
  late final Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;

    // Initial check
    checkConnection();

    // Listen for connectivity changes
    _connectivityStream.listen((List<ConnectivityResult> results) {
      final hasConnection =
          results.isNotEmpty && results.first != ConnectivityResult.none;

      if (!hasConnection) {
        hasInternet.value = false;
        showCustomSnackBar('offline_message'.tr, isError: true);
      } else {
        if (hasInternet.value == false) {
          showCustomSnackBar('online_back_message'.tr, isError: false);
        }
        hasInternet.value = true;
      }
    });
  }

  Future<void> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    hasInternet.value =
        results.isNotEmpty && results.first != ConnectivityResult.none;
  }
}
