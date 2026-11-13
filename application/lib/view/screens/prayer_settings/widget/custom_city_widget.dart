// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/helper/salat_waqt_service.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';

class CustomCityDialog extends StatelessWidget {
  const CustomCityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerTimeController = Get.find<PrayerTimeController>();
    prayerTimeController.loadPrayerTimeSettings();

    return Center(
      child: AlertDialog(
        backgroundColor: Get.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: Get.width / 1.3,
          height: Get.height * 0.75,
          child: Column(
            children: [
              // Search Box
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      Dimensions.RADIUS_SMALL,
                    ),
                  ),
                  child: TextField(
                    controller: prayerTimeController.citySearchController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'search'.tr,
                      hintStyle: robotoRegular.copyWith(fontSize: 14),
                    ),
                    onChanged: (value) =>
                        prayerTimeController.search.value = value,
                  ),
                ),
              ),

              // My Location Option
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(AppConstants.isPrayerTme, false);
                    // Automatic mode → no manual city. Clear any previously saved one.
                    await prefs.remove(AppConstants.saveCityName);

                    // getLocation() already calls fetchPrayerTime() internally with
                    // isManualPrayerTme: false and the current address, so don't call
                    // fetchPrayerTime() here — it would double-fetch.
                    await prayerTimeController.getLocation();
                    Get.back();
                    SalatWaqtService.initializeSalatWaqt();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          Images.Icon_Location,
                          height: 20,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'my_location'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_LARGE,
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.grey.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(thickness: 1.2),

              // City List
              Expanded(
                child: Obx(() {
                  if (prayerTimeController.isCityListLoading.value) {
                    return const Center(child: LoadingIndicator());
                  }

                  final cityList =
                      prayerTimeController.cityModelData?.data ?? [];

                  final filteredList = cityList
                      .where(
                        (city) => city.toLowerCase().contains(
                          prayerTimeController.search.value.toLowerCase(),
                        ),
                      )
                      .toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Text(
                        'no_data_found'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const Divider(thickness: 0.7),
                    itemBuilder: (context, index) {
                      final cityName = filteredList[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool(AppConstants.isPrayerTme, true);
                            await prefs.setString(
                              AppConstants.saveCityName,
                              cityName,
                            );

                            await prayerTimeController.fetchPrayerTime(
                              isManualPrayerTme: true,
                              manualCity: cityName,
                            );
                            // Do NOT call getLocation() here — manual mode uses the picked city,
                            // not GPS. getLocation() would overwrite currentAddress with GPS.
                            Get.back();
                            SalatWaqtService.initializeSalatWaqt();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Images.Icon_Location,
                                  height: 20,
                                  color: Theme.of(context).hintColor,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    cityName,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.FONT_SIZE_LARGE,
                                      color: Get.isDarkMode
                                          ? Colors.white
                                          : Colors.grey.shade900,
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
