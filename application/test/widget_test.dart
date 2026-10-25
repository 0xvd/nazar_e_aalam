import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/main.dart';
import 'package:nazar_e_alam/helper/get_di.dart' as di;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts successfully', (tester) async {
    SharedPreferences.setMockInitialValues({});

    debugPrint('STEP 1: Starting dependency initialization');
    final languages = await di.init();
    debugPrint('STEP 2: Dependencies initialized');

    await tester.pumpWidget(MyApp(languages: languages));
    debugPrint('STEP 3: App widget built');

    expect(find.byType(MyApp), findsOneWidget);

    // Advance the fake clock so the 3-second splash timer fires.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    debugPrint('STEP 4: Splash timer processed');

    Get.reset();
  });
}
