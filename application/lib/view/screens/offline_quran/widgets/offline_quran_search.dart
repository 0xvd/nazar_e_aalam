// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/offline_quran_controller.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';
import 'package:nazar_e_alam/view/screens/offline_quran/offline_surah_detail_screen.dart';

import '../../../../controller/quran_settings_controller.dart';

class OfflineQuranSearchScreen extends StatelessWidget {
  OfflineQuranSearchScreen({super.key});

  final OfflineQuranController ctrl = Get.put(OfflineQuranController());

  @override
  Widget build(BuildContext context) {
    ctrl.initLoader();
    ctrl.clearSearch();
    return Scaffold(
      appBar: SearchableAppBar(),
      body: Column(
        children: [
          // Loading indicator while initial load happens
          Obx(() {
            if (ctrl.isQuranSearching.value) {
              return const Expanded(child: Center(child: LoadingIndicator()));
            }

            return Expanded(
              child: Obx(() {
                if (ctrl.results.isEmpty) {
                  return Center(child: Text('no_data_found'.tr));
                }

                return ListView.builder(
                  itemCount: ctrl.results.length,
                  itemBuilder: (context, index) {
                    final verse = ctrl.results[index];
                    final chapter =
                        verse['chapter'] as Map<String, dynamic>? ?? {};

                    return InkWell(
                      onTap: () {
                        // // Handle verse tap if needed

                        Get.to(
                          OfflineSuraDetaileScreen(
                            appBackButton: true,
                            surahNumber: chapter['id'].toString(),
                          ),
                          arguments: {
                            'highlightedWord': verse['arabic_name'],
                            'pageNumber': verse['page_key'],
                          },
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        color: Theme.of(context).cardColor,
                        shadowColor: Get.isDarkMode
                            ? Colors.grey[800]!
                            : Colors.grey[200]!,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              // arabic ayah ==>
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(
                                  () => Text(
                                    "${chapter['arabic_name']}",
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style: robotoMedium.copyWith(
                                      fontSize: Get.find<SettingsController>()
                                          .arabicFontSize
                                          .value,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                              ),

                              // arabic ayah ==>
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(
                                  () => Text(
                                    verse['arabic_name'] ?? '',
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style: Get.find<SettingsController>()
                                        .selectedArabicFont
                                        .copyWith(
                                          fontSize:
                                              Get.find<SettingsController>()
                                                  .arabicFontSize
                                                  .value,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.color,
                                        ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: Dimensions.PADDING_SIZE_SMALL,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // end ayah image
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          Images.Icon_End_Ayah,
                                          height: 45,
                                          fit: BoxFit.fill,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        Text(
                                          verse['verse_number']?.toString() ??
                                              '',
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_SMALL,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class SearchableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isBackButtonExist;

  SearchableAppBar({super.key, this.isBackButtonExist = true});

  final OfflineQuranController ctrl = Get.put(OfflineQuranController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Get.isDarkMode
          ? Theme.of(context).cardColor
          : Theme.of(context).primaryColor,
      elevation: 0,
      leading: isBackButtonExist
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyMedium!.color
                    : Theme.of(context).cardColor,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: SizedBox(
          height: 40,
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: searchController,
              autofocus: true,
              onChanged: (v) {
                if (kDebugMode) {
                  print("search data =====> $v");
                }
                ctrl.search(v);
              },
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyMedium!.color
                    : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "search_ayah".tr,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                  vertical: Dimensions.PADDING_SIZE_SMALL,
                ),
                filled: true,
                fillColor: Get.isDarkMode
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Dimensions.RADIUS_DEFAULT,
                  ),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          ctrl.clearSearch();
                          // Remove focus when clearing search
                          FocusScope.of(context).unfocus();
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(GetPlatform.isDesktop ? 70 : 56);
}
