// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
// import 'package:nazar_e_alam/util/app_constants.dart';
// import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

// import '../data/model/response/islamic_name_model.dart';
// import '../data/repository/islamic_name_repo.dart';

// class IslamicNameController extends GetxController
//     with GetSingleTickerProviderStateMixin {
//   // in IslamicNameController
//   final featuredCardKey = GlobalKey();
//   final shareButtonKey = GlobalKey();
//   final _service = IslamicNameRepo();

//   // ── Filter observables ────────────────────────
//   final gender = 'any'.obs;
//   final origin = 'any'.obs;
//   final themeCtrl = TextEditingController();
//   final letterCtrl = TextEditingController();

//   // ── State observables ─────────────────────────
//   final names = <IslamicName>[].obs;
//   final favorites = <IslamicName>[].obs;
//   final featured = Rxn<IslamicName>();
//   final isLoading = false.obs;
//   final error = Rxn<String>();

//   // ── Animation ─────────────────────────────────
//   late AnimationController fadeCtrl;
//   late Animation<double> fadeAnim;

//   @override
//   void onInit() {
//     super.onInit();
//     fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     fadeAnim = CurvedAnimation(parent: fadeCtrl, curve: Curves.easeIn);
//     _loadFavorites();
//   }

//   @override
//   void onClose() {
//     themeCtrl.dispose();
//     letterCtrl.dispose();
//     fadeCtrl.dispose();
//     super.onClose();
//   }

//   // ── SharedPreferences: Load ───────────────────
//   Future<void> _loadFavorites() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? raw = prefs.getString(AppConstants.FAVORITE_KEY);
//       if (raw != null && raw.isNotEmpty) {
//         final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
//         final loaded = jsonList
//             .map((e) => IslamicName.fromJson(Map<String, dynamic>.from(e)))
//             .toList();
//         favorites.assignAll(loaded);
//       }
//     } catch (e) {
//       debugPrint('Failed to load favorites: $e');
//     }
//   }

//   // ── SharedPreferences: Save ───────────────────
//   Future<void> _saveFavorites() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String encoded = jsonEncode(
//         favorites.map((n) => n.toJson()).toList(),
//       );
//       await prefs.setString(AppConstants.FAVORITE_KEY, encoded);
//     } catch (e) {
//       debugPrint('Failed to save favorites: $e');
//     }
//   }

//   // ── Generate ──────────────────────────────────
//   Future<void> generate(BuildContext context) async {
//     FocusScope.of(context).unfocus();
//     isLoading.value = true;
//     error.value = null;
//     names.clear();
//     featured.value = null;
//     fadeCtrl.reset();

//     try {
//       final result = await _service.generateNames(
//         islamicNameApiKey: Get.find<SettingsController>()
//             .mosqueSettingsApiData
//             ?.data
//             ?.islamicNameApiKey.toString(),
//         gender: gender.value,
//         origin: origin.value,
//         meaningTheme: themeCtrl.text.trim().isEmpty
//             ? null
//             : themeCtrl.text.trim(),
//         startsWithLetter: letterCtrl.text.trim().isEmpty
//             ? null
//             : letterCtrl.text.trim(),
//       );

//       // Mark already-favorited names so the heart icon stays filled
//       for (final name in result) {
//         if (favorites.any((f) => f.english == name.english)) {
//           name.isFavorite = true;
//         }
//       }

//       names.assignAll(result);
//       featured.value = result.isNotEmpty ? result.first : null;
//       fadeCtrl.forward();
//     } catch (e) {
//       error.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ── Select featured ───────────────────────────
//   void selectFeatured(IslamicName name) {
//     featured.value = name;
//     fadeCtrl
//       ..reset()
//       ..forward();
//   }

//   // ── Toggle favorite ───────────────────────────
//   void toggleFavorite(IslamicName name) {
//     name.isFavorite = !name.isFavorite;

//     if (name.isFavorite) {
//       if (!favorites.any((f) => f.english == name.english)) {
//         favorites.add(name);
//       }
//     } else {
//       favorites.removeWhere((f) => f.english == name.english);
//     }

//     // Refresh observables
//     names.refresh();
//     favorites.refresh();

//     // Persist to SharedPreferences
//     _saveFavorites();
//   }

//   // ── Copy name ─────────────────────────────────
//   void copyName(BuildContext context, IslamicName name) {
//     Clipboard.setData(
//       ClipboardData(text: '${name.english} (${name.arabic}) — ${name.meaning}'),
//     );

//     showCustomSnackBar(
//       'Copied: ${name.english} (${name.arabic}) — ${name.meaning}',
//     );
//   }

//   // ── Remove from favorites ─────────────────────
//   void removeFavorite(IslamicName name) {
//     name.isFavorite = false;
//     favorites.remove(name);
//     names.refresh();
//     favorites.refresh();

//     // Persist to SharedPreferences
//     _saveFavorites();
//   }
// }
