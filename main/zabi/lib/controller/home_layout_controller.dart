import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class HomeLayoutController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  HomeLayoutController({required this.sharedPreferences}) {
    _loadSaved();
  }

  static const String modern = 'modern';
  static const String classic = 'classic';
  static const Set<String> validLayouts = {modern, classic};

  final RxString currentLayout = modern.obs;
  bool _hasUserOverride = false;

  void _loadSaved() {
    final saved = sharedPreferences.getString(
      AppConstants.HOME_LAYOUT_OVERRIDE_KEY,
    );
    if (saved != null && validLayouts.contains(saved)) {
      _hasUserOverride = true;
      currentLayout.value = saved;
    }
  }

  /// Applies the layout coming from the /api/settings `home_layout` field.
  /// Ignored once the user has manually chosen a layout from Settings.
  void applyApiValue(String? apiValue) {
    if (_hasUserOverride) return;
    final normalized = apiValue?.trim().toLowerCase();
    currentLayout.value = validLayouts.contains(normalized)
        ? normalized!
        : modern;
  }

  Future<void> setUserLayout(String layout) async {
    if (!validLayouts.contains(layout)) return;
    _hasUserOverride = true;
    currentLayout.value = layout;
    await sharedPreferences.setString(
      AppConstants.HOME_LAYOUT_OVERRIDE_KEY,
      layout,
    );
  }
}
