// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:nazar_e_alam/controller/bookmark_controller.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/controller/offline_quran_controller.dart';
import 'package:nazar_e_alam/data/model/response/bookmark_model.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';

import '../../../../controller/quran_settings_controller.dart';
import '../../../base/custom_snackbar.dart';

class OfflineArabicQuranAutoDetectScreen extends StatefulWidget {
  final int? pageNumber;
  final String? highlightedWord;
  const OfflineArabicQuranAutoDetectScreen({
    super.key,
    this.pageNumber,
    this.highlightedWord,
  });

  @override
  _OfflineArabicQuranAutoDetectScreenState createState() =>
      _OfflineArabicQuranAutoDetectScreenState();
}

class _OfflineArabicQuranAutoDetectScreenState
    extends State<OfflineArabicQuranAutoDetectScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  late int initialIndex;
  bool _isListBuilt = false;
  int detectedPageIndex = 0;

  late String? highlightedText;

  @override
  void initState() {
    super.initState();
    initialIndex = widget.pageNumber ?? 0;
    highlightedText = widget.highlightedWord;
  }

  void _scrollToIndex(int index) {
    if (_isListBuilt) {
      _scrollController.scrollTo(
        index: index,
        duration: Duration(
          seconds: index < 3
              ? 1
              : index < 5
              ? 2
              : index < 8
              ? 3
              : 4,
        ),
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

  Widget _buildAyahText(
    BuildContext context,
    String text,
    String? highlightedText,
  ) {
    return Obx(() {
      // If highlight text is null or empty, return normal SelectableText
      if (highlightedText == null || highlightedText.isEmpty) {
        return SelectableText(
          text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: Get.find<SettingsController>().selectedArabicFont.copyWith(
            fontSize: Get.find<SettingsController>().arabicFontSize.value,
            color: Get.isDarkMode
                ? Colors.black54
                : Theme.of(context).textTheme.bodyMedium!.color,
          ),
        );
      }

      final spans = <TextSpan>[];
      int start = 0;

      while (true) {
        final index = text.indexOf(highlightedText, start);
        if (index == -1) {
          // Add remaining text
          spans.add(
            TextSpan(
              text: text.substring(start),
              style: Get.find<SettingsController>().selectedArabicFont.copyWith(
                fontSize: Get.find<SettingsController>().arabicFontSize.value,
                color: Get.isDarkMode
                    ? Colors.black54
                    : Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          );
          break;
        }

        // Add text before highlight
        if (index > start) {
          spans.add(
            TextSpan(
              text: text.substring(start, index),
              style: Get.find<SettingsController>().selectedArabicFont.copyWith(
                fontSize: Get.find<SettingsController>().arabicFontSize.value,
                color: Get.isDarkMode
                    ? Colors.black54
                    : Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          );
        }

        // Add highlighted text
        spans.add(
          TextSpan(
            text: text.substring(index, index + highlightedText.length),
            style: robotoMedium.copyWith(
              fontSize: Get.find<SettingsController>().arabicFontSize.value,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        start = index + highlightedText.length;
      }

      return SelectableText.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      );
    });
  }

  Widget _buildPageNumber(BuildContext context, String pageNumber) {
    return Center(
      child: SelectableText(
        pageNumber,
        textAlign: TextAlign.center,
        style: robotoMedium.copyWith(
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(
    BuildContext context,
    OfflineQuranController quranController,
    int index,
  ) {
    return GetBuilder<BookMarkController>(
      builder: (bookMarkController) {
        final apiData =
            quranController.suraDetailsApiData!.data!.chapterInfo![index];

        final pageKey = apiData.pageKey ?? "0";

        final pageNumber = int.parse(
          "${quranController.suraDetailsApiData!.data!.chapter!.id}00000$pageKey",
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
                  final suraInfo = quranController.suraDetailsApiData!.data!;

                  final bookMark = BookMark(
                    id: pageNumber,
                    suraName:
                        Get.find<LocalizationController>()
                                .locale
                                .languageCode ==
                            "ar"
                        ? suraInfo.chapter!.arabicName.toString()
                        : suraInfo.chapter!.translatedName.toString(),
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
    OfflineQuranController suraDetaileController,
    int index,
    String highlightedText,
  ) {
    // Get.find<MosqueSettingsController>().fetchMosqueSettingsData();
    final apiData =
        suraDetaileController.suraDetailsApiData!.data!.chapterInfo![index];

    return Container(
      padding: Get.find<SettingsController>().arabicFontSize.value <= 25
          ? const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL + 5)
          : const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL + 20),
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        image: const DecorationImage(
          image: AssetImage(Images.Quran_Frame),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAyahText(context, apiData.pageArabicAyah!, highlightedText),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                child: _buildPageNumber(context, apiData.pageNumber.toString()),
              ),
              Expanded(
                child: _buildBookmarkButton(
                  context,
                  suraDetaileController,
                  index,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OfflineQuranController>(
        builder: (suraDetaileController) {
          if (suraDetaileController.isSurahDetailsLoading.value) {
            return const Center(child: LoadingIndicator());
          }

          return ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemPositionsListener: _itemPositionsListener,
            itemCount: suraDetaileController
                .suraDetailsApiData!
                .data!
                .chapterInfo!
                .length,
            itemBuilder: (context, index) {
              if (!_isListBuilt) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _isListBuilt = true;
                  _scrollToIndex(initialIndex);
                  setState(() {});
                  suraDetaileController.update();
                });
              }
              return Column(
                children: [
                  if (suraDetaileController
                              .suraDetailsApiData!
                              .data!
                              .chapter!
                              .id !=
                          1 &&
                      suraDetaileController
                              .suraDetailsApiData!
                              .data!
                              .chapter!
                              .id !=
                          9 &&
                      index == 0)
                    _buildBismillah(context),
                  _buildAyahContainer(
                    context,
                    suraDetaileController,
                    index,
                    highlightedText!,
                  ),
                  const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
