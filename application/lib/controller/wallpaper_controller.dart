// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, strict_top_level_inference

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_setter/wallpaper_setter.dart';
import 'package:nazar_e_alam/data/model/response/wallpaper_model.dart';

import '../data/repository/wallpaper_repo.dart';

class WallPaperController extends GetxController implements GetxService {
  final WallpaperRepo wallpaperRepo;

  WallPaperController({required this.wallpaperRepo});

  RxBool isWallPaperListLoading = false.obs;

  WallpaperModel? wallpaperModelData;
  var selectedCategory = ''.obs;

  bool isHomeChecked = true; // For first checkbox
  bool isLockChecked = true; // For second checkbox

  setHomeCheckedValue(homeCheckedValue) {
    isHomeChecked = homeCheckedValue;

    update();
  }

  setLockCheckedValue(lockCheckedValue) {
    isLockChecked = lockCheckedValue;

    update();
  }

  setWallpaperCategoryValue(type) {
    selectedCategory = type;

    update();
  }

  Future<void> wallpaperCategoryListData() async {
    try {
      isWallPaperListLoading(true);
      update();

      final response = await wallpaperRepo.getWallpaperLisRepo();

      if (response.statusCode == 200) {
        wallpaperModelData = WallpaperModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isWallPaperListLoading(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  Future<void> wallpaperCategoryListDetails(String category) async {
    try {
      isWallPaperListLoading(true);
      update();

      final response = await wallpaperRepo.getWallpaperLisRepo();

      if (response.statusCode == 200) {
        wallpaperModelData = WallpaperModel.fromJson(response.body);

        // Set selected category to passed category
        selectedCategory.value = category;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isWallPaperListLoading(false);
      update();
    }
  }

  List<Wallpapers> get filteredWallpapers {
    final categoryData = wallpaperModelData!.data?.firstWhereOrNull(
      (element) => element.category == selectedCategory.value,
    );
    return categoryData?.wallpapers ?? [];
  }

  Future<void> shareFilePdf(imageUrl) async {
    try {
      // Download file bytes
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final fileName = imageUrl.split('/').last;
        final filePath = '${tempDir.path}/$fileName';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Share the file
        final result = await Share.shareXFiles(
          [XFile(filePath)],
        );

        if (result.status == ShareResultStatus.success) {
          debugPrint('Thank you for sharing my PDF!');
        }
      } else {
        debugPrint('Failed to download file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  final GlobalKey previewContainer = GlobalKey();

  Future<void> handleUseAs(context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Call wallpaper plugin
    await WallpaperPlugin.useAsImageFromRepaintBoundary(
      previewContainer,
    );

    // Hide loading dialog
    Navigator.of(context, rootNavigator: true).pop();
  }
}
