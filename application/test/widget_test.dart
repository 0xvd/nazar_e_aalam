import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/main.dart';
import 'package:nazar_e_alam/helper/get_di.dart' as di;
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/helper/theme_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts successfully', (tester) async {
    SharedPreferences.setMockInitialValues({});

    debugPrint('STEP 1: Starting dependency initialization');
    final languages = await di.init();
    debugPrint('STEP 2: Dependencies initialized');

    // Create themes the same way main() does
    final layoutController = Get.find<HomeLayoutController>();
    final lightTheme = getAppTheme(layoutController.currentLayout.value, false);
    final darkTheme = getAppTheme(layoutController.currentLayout.value, true);

    await tester.pumpWidget(MyApp(
      languages: languages,
      lightTheme: lightTheme,
      darkTheme: darkTheme,
    ));
    debugPrint('STEP 3: App widget built');

    expect(find.byType(MyApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    debugPrint('STEP 4: Splash timer processed');

    Get.reset();
  });
}