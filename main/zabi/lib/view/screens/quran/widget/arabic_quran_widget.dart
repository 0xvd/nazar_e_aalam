// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:nazar_e_alam/controller/bookmark_controller.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/data/model/response/bookmark_model.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class ArabicQuranWidget extends StatefulWidget {
  final int? pageNumber;
  const ArabicQuranWidget({super.key, this.pageNumber});

  @override
  _ArabicQuranWidgetState createState() => _ArabicQuranWidgetState();
}

class _ArabicQuranWidgetState extends State<ArabicQuranWidget> {
  final ItemScrollController _scrollController = ItemScrollController();
  late int initialIndex;
  bool _isListBuilt = false;

  @override
  void initState() {
    super.initState();
    initialIndex = widget.pageNumber ?? 0;
    if (kDebugMode) {
      print("Page number: $initialIndex");
    }
  }

  void _scrollToIndex(int index) {
    if (_isListBuilt) {
      _scrollController.scrollTo(
        index: index,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildBismillah(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              Images.Bismillah,
              height: 50,
              fit: BoxFit.fitHeight,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAyahText(BuildContext context, String text) {
    return Obx(
      () => SelectableText(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: Get.find<SettingsController>().selectedArabicFont.copyWith(
          fontSize: Get.find<SettingsController>().arabicFontSize.value,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
    );
  }

  Widget _buildPageNumber(BuildContext context, String pageNumber) {
    return SelectableText(
      pageNumber,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      style: robotoMedium.copyWith(
        color: Get.isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildBookmarkButton(
    BuildContext context,
    QuranController quranController,
    int index,
  ) {
    return GetBuilder<BookMarkController>(
      init: BookMarkController(),
      builder: (bookMarkController) {
        final pageKey =
            quranController
                .suraDetaileApiData!
                .data!
                .chapterInfo![index]
                .pageKey ??
            "0";

        final pageNumber = int.parse(
          "${quranController.suraDetaileApiData!.data!.chapter!.id}00000$pageKey",
        );

        final isPageExists = bookMarkController.bookMarks.any(
          (bookmark) => bookmark.id == pageNumber,
        );

        return isPageExists
            ? IconButton(
                onPressed: () {
                  showCustomSnackBar(
                    "already_added_in_your_bookmark".tr,
                    isError: true,
                  );
                },
                icon: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).primaryColor,
                ),
              )
            : IconButton(
                iconSize: 35,
                onPressed: () {
                  final suraInfo = quranController.suraDetaileApiData!.data!;
                  final bookMark = BookMark(
                    id: pageNumber,
                    suraName: suraInfo.chapter!.translatedName.toString(),
                    serialNumber: suraInfo.chapter!.id.toString(),
                    versesNumber: "",
                    arabicName: suraInfo.chapterInfo![index].pageArabicAyah
                        .toString(),
                    translatedName: "",
                    pageKey: suraInfo.chapterInfo![index].pageKey.toString(),
                    pageNumber: suraInfo.chapterInfo![index].pageNumber
                        .toString(),
                  );
                  bookMarkController.insertBookMark(bookMark);
                },
                icon: SvgPicture.asset(
                  Images.Icon_Bookmark,
                  height: 28,
                  color: Theme.of(context).primaryColor,
                ),
              );
      },
    );
  }

  Widget _buildAyahContainer(
    BuildContext context,
    QuranController quranController,
    int index,
  ) {
    final apiData =
        quranController.suraDetaileApiData!.data!.chapterInfo![index];

    return Container(
      padding: Get.find<SettingsController>().arabicFontSize.value <= 25
          ? const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL + 5)
          : const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        image: const DecorationImage(
          image: AssetImage(Images.Quran_Frame),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          _buildAyahText(context, apiData.pageArabicAyah.toString()),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                child: _buildPageNumber(context, apiData.pageNumber.toString()),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildBookmarkButton(context, quranController, index),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuranController>(
      builder: (quranController) {
        if (quranController.isSuraDetaileLoading.value ||
            quranController.suraDetaileApiData == null) {
          return const Center(
            child: SingleChildScrollView(child: ArabicTranslationShimmer()),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ScrollablePositionedList.builder(
                itemCount: quranController
                    .suraDetaileApiData!
                    .data!
                    .chapterInfo!
                    .length,
                itemScrollController: _scrollController,
                itemBuilder: (context, index) {
                  if (!_isListBuilt) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _isListBuilt = true;
                      _scrollToIndex(initialIndex);
                      setState(() {});
                      quranController.update();
                    });
                  }

                  return Column(
                    children: [
                      if (quranController
                                  .suraDetaileApiData!
                                  .data!
                                  .chapter!
                                  .id !=
                              1 &&
                          quranController
                                  .suraDetaileApiData!
                                  .data!
                                  .chapter!
                                  .id !=
                              9 &&
                          index == 0)
                        _buildBismillah(context),
                      _buildAyahContainer(context, quranController, index),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
