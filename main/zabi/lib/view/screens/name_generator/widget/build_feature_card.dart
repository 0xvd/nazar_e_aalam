// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../controller/islamic_name_controller.dart';
import '../../../../controller/quran_settings_controller.dart';
import '../../../../data/model/response/islamic_name_model.dart';
import '../../../../theme/light_theme.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/images.dart';
import '../../../../util/styles.dart';

// ── Featured Card ─────────────────────────────
Widget buildFeaturedCard(
  BuildContext context,
  IslamicNameController ctrl,
  IslamicName name,
) {
  return RepaintBoundary(
    key: ctrl.featuredCardKey,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_DEFAULT),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_DEFAULT),
        ),
        child: Stack(
          children: [
            // ── SVG background (full cover) ───────
            Positioned.fill(
              child: SvgPicture.asset(
                Images.bgFeaturedCard,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.15),
                  BlendMode.srcIn,
                ),
              ),
            ),

            // ── Card content ──────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                child: Column(
                  children: [
                    // ── Action row ─────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(
                            () => IconButton(
                              padding: EdgeInsets.all(2),
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                ctrl.featured.value?.isFavorite == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: ctrl.featured.value?.isFavorite == true
                                    ? Theme.of(context).colorScheme.error
                                    : AppColor.cardColor,
                                size: 22,
                              ),
                              onPressed: () => ctrl.toggleFavorite(name),
                            ),
                          ),

                          IconButton(
                            padding: EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.copy,
                              size: 18,
                              color: AppColor.cardColor,
                            ),
                            onPressed: () => ctrl.copyName(context, name),
                          ),

                          IconButton(
                            key: ctrl.shareButtonKey,
                            padding: EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.share,
                              size: 20,
                              color: AppColor.cardColor,
                            ),
                            onPressed: () => _shareCardAsImage(context, ctrl),
                          ),
                        ],
                      ),
                    ),
                    // ── Arabic name ────────────────
                    Text(
                      name.arabic,
                      style: Get.find<SettingsController>().selectedArabicFont
                          .copyWith(
                            fontSize: 44,
                            color: AppColor.cardColor,
                            height: 1.4,
                            fontWeight: FontWeight.w300,
                          ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // ── English name ───────────────
                    Text(
                      name.english,
                      style: robotoBlack.copyWith(
                        fontSize: 26,
                        color: AppColor.cardColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Tags ───────────────────────
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _chip(
                          name.meaning,
                          AppColor.greenColorBG,
                          AppColor.greenColorText,
                        ),
                        _chip(
                          name.origin,
                          AppColor.tealColorBG,
                          AppColor.tealColorText,
                        ),
                        _chip(
                          name.gender == 'boy' ? 'Boy' : 'Girl',
                          AppColor.blueColor,
                          AppColor.blueColorText,
                        ),
                      ],
                    ),

                    // ── Quranic reference ──────────
                    if (name.quranicReference != null &&
                        name.quranicReference != 'null' &&
                        name.quranicReference!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? AppColor.primaryColor.withValues(alpha: 0.1)
                              : AppColor.goldColor.withValues(alpha: 0.01),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Get.isDarkMode
                                ? AppColor.primaryColor.withValues(alpha: 0.3)
                                : AppColor.goldColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book,
                              size: 14,
                              color: AppColor.cardColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              name.quranicReference!,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.FONT_SIZE_SMALL,
                                color: AppColor.cardColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Share card as image ───────────────────────
Future<void> _shareCardAsImage(
  BuildContext context,
  IslamicNameController ctrl,
) async {
  BuildContext? loaderCtx;

  try {
    // Wait for the current frame to finish painting
    await WidgetsBinding.instance.endOfFrame;

    // ── Validate card key ─────────────────────
    final cardContext = ctrl.featuredCardKey.currentContext;
    if (cardContext == null) throw Exception('Card not visible.');

    final renderObject = cardContext.findRenderObject();
    if (renderObject == null || renderObject is! RenderRepaintBoundary) {
      throw Exception('RenderRepaintBoundary not found.');
    }

    // ── Resolve share button position for iOS popover ─────────
    Rect shareButtonRect = Rect.zero;
    final btnContext = ctrl.shareButtonKey.currentContext;
    if (btnContext != null) {
      final box = btnContext.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final offset = box.localToGlobal(Offset.zero);
        shareButtonRect = offset & box.size; // Rect from offset + size
      }
    }

    // Fallback: centre of screen if button rect is still zero
    if (shareButtonRect == Rect.zero) {
      final size = MediaQuery.of(context).size;
      shareButtonRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 1,
        height: 1,
      );
    }

    // ── Show loader ───────────────────────────
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          loaderCtx = ctx;
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        },
      );
    }

    // ── Capture widget as PNG ─────────────────
    final ui.Image image = await renderObject.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) throw Exception('Image byte conversion failed.');

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // ── Save to temp file ─────────────────────
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath =
        '${tempDir.path}/islamic_name_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(filePath).writeAsBytes(pngBytes);

    // ── Close loader ──────────────────────────
    if (loaderCtx != null && context.mounted) Navigator.pop(loaderCtx!);

    // ── Open native share sheet ───────────────
    // sharePositionOrigin is required on iOS to anchor the popover
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'generated_with'.tr,
      sharePositionOrigin: shareButtonRect,
    );
  } catch (e) {
    if (loaderCtx != null && context.mounted) Navigator.pop(loaderCtx!);

    debugPrint('Share error: $e');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Widget _chip(String label, Color bg, Color fg) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, color: fg)),
  );
}
