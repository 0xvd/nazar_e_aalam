// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/helper/salat_waqt_service.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/prayer_settings/widget/custom_prayer_dropdown.dart';

import 'widget/custom_city_widget.dart';

class PrayerTimeCalculationSettings extends StatelessWidget {
  const PrayerTimeCalculationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Get.find<PrayerTimeController>().getLocation();
      Get.find<PrayerTimeController>().cityCategoryListData();
      Get.find<PrayerTimeController>().fetchPrayerTime();
    });
    Get.put(PrayerTimeController(apiClient: Get.find()));
    Get.find<PrayerTimeController>().loadPrayerTimeSettings();
    Get.find<PrayerTimeController>().loadSwitchValue();

    return GetBuilder<PrayerTimeController>(
      builder: (prayerTimeController) {
        prayerTimeController.loadPrayerTimeSettings();
        return ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.all(5),
          title: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ExpansionTile(
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide.none,
              ),
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              expansionAnimationStyle: AnimationStyle(
                duration: const Duration(milliseconds: 500),
              ),
              clipBehavior: Clip.antiAlias,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        Images.Icon_Ramadan_Time,
                        width: 25,
                        height: 25,
                        fit: BoxFit.fill,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                      Text(
                        "prayer_time_settings".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.FONT_SIZE_DEFAULT,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Text(
                        'set_prayer_time_format'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Container(
                        padding: const EdgeInsets.only(
                          left: Dimensions.PADDING_SIZE_GRID_SMALL,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.RADIUS_DEFAULT,
                          ),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'show_prayer_time_formation_as_a_24_hr_clock'
                                      .tr,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              activeColor: Theme.of(context).primaryColor,
                              activeTrackColor: Theme.of(context).primaryColor,
                              inactiveThumbColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              inactiveTrackColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              value: prayerTimeController.is24HourFormat.value,
                              onChanged: (value) async {
                                prayerTimeController.updateSwitchValue(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Text(
                        'city_settings'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      InkWell(
                        onTap:
                            prayerTimeController.cityModelData != null &&
                                prayerTimeController.cityModelData!.data !=
                                    null &&
                                prayerTimeController
                                    .cityModelData!
                                    .data!
                                    .isNotEmpty
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const CustomCityDialog();
                                  },
                                );
                              }
                            : () {
                                debugPrint(
                                  "city Data is null or empty. Dialog not opening.",
                                );
                              },
                        child: Container(
                          height: 50,
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.RADIUS_DEFAULT,
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: Dimensions.PADDING_SIZE_DEFAULT,
                                ),
                                child: Obx(
                                  () => Text(
                                    prayerTimeController
                                            .saveAddress
                                            .value
                                            .isNotEmpty
                                        ? prayerTimeController.saveAddress.value
                                              .toString()
                                        : prayerTimeController
                                              .currentAddress
                                              .value,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.FONT_SIZE_DEFAULT,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                ),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      if (prayerTimeController.isPrayerTimes.value == false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'prayer_method_settings'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            CustomPrayerSettingDropDown(
                              dwItems: prayerTimeController.calculationMethod,
                              dwValue: prayerTimeController
                                  .selectedCalculationMethod,
                              hintText: 'choose_a_prayer_key'.tr,
                              dropdownHeight: 500,
                              onChange: (value) {
                                prayerTimeController
                                    .setSelectedCalculationMethod(value);
                                SalatWaqtService.initializeSalatWaqt();
                              },
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            Text(
                              'prayer_madhab_settings'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            CustomPrayerSettingDropDown(
                              bgColor: Colors.transparent,
                              dwItems: prayerTimeController.prayerMadhabList,
                              dwValue:
                                  prayerTimeController.selectedPrayerMadhab,
                              hintText: 'choose_a_madhad_key'.tr,
                              borderColor: Theme.of(
                                context,
                              ).disabledColor.withOpacity(0.5),
                              onChange: (value) {
                                prayerTimeController.setSelectedPrayerMadhab(
                                  value,
                                );
                                SalatWaqtService.initializeSalatWaqt();
                              },
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_SIZE_SMALL,
                            ),
                          ],
                        ),

                      if (prayerTimeController.isPrayerTimes.value == false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'adjust_prayer_time'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(
                                Dimensions.RADIUS_DEFAULT,
                              ),
                              onTap: () {
                                Get.toNamed(RouteHelper.prayerAdjustment);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_DEFAULT,
                                  ),
                                  color: Theme.of(context).cardColor,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.5),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    /// Text Section
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'customize_prayer_time_offsets_for_each_prayer'
                                                .tr,
                                            style: robotoMedium.copyWith(),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Arrow Icon
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
