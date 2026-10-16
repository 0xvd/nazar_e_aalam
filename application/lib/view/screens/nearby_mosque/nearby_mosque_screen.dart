// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/nearby_mosque_controller.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/view/base/location_error_widget.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';

class NearbyMosque extends StatelessWidget {
  final bool appBackButton;
  const NearbyMosque({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    Get.put(NearbyMosqueController()).getLocation();
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: 'nearby_mosque'.tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),

      // body start ==>
      body: SingleChildScrollView(
        child: GetBuilder<NearbyMosqueController>(
          init: NearbyMosqueController(),
          builder: (nearbyMosqueController) {
            return Obx(
              () =>
                  nearbyMosqueController.isLoading.value ||
                      nearbyMosqueController.userLocation.value == ""
                  ? SizedBox(
                      height: Get.height / 1.2,
                      child: Center(
                        child:
                            nearbyMosqueController.isLocationDenied.value ==
                                true
                            ? LocationErrorWidget(
                                error:
                                    "location_service_permission_denied_for_getting_this_service_please_enable_location"
                                        .tr,
                              )
                            : const NearbyMosqueShimmerScreen(),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.PADDING_SIZE_SMALL,
                        vertical: Dimensions.PADDING_SIZE_SMALL,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "if_you_cant_find_the_mosque_according_to_the_predefined_area_then_search_for_the_mosque_by_selecting_area_by_kilometers_from_below"
                                .tr,
                            textAlign: TextAlign.justify,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // dropdown ==>
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_SMALL,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL,
                                ),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                ),
                                child: DropdownButton<String>(
                                  menuMaxHeight: 500,
                                  value: nearbyMosqueController.km.value,
                                  items:
                                      <String>[
                                        '1  KM',
                                        '2  KM',
                                        '3  KM',
                                        '4  KM',
                                        '5  KM',
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(translateText(value)),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    nearbyMosqueController.loadKmDropdownValue(
                                      newValue!,
                                    );
                                    nearbyMosqueController.searchNearbyPlaces();
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // list view ===>
                          ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: nearbyMosqueController.places.length,
                            itemBuilder: (BuildContext context, int index) {
                              var place = nearbyMosqueController.places[index];
                              double lat = place["geometry"]["location"]["lat"];
                              double lng = place["geometry"]["location"]["lng"];
                              return GestureDetector(
                                onTap: () async {
                                  final url =
                                      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                                  final canLaunchUrl = await canLaunch(url);

                                  if (canLaunchUrl) {
                                    await launch(url);
                                  } else {
                                    showCustomSnackBar(
                                      "please_try_again".tr,
                                      isError: true,
                                    );
                                  }
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: Theme.of(context).cardColor,
                                  shadowColor: Get.isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsetsDirectional.symmetric(
                                          horizontal:
                                              Dimensions.PADDING_SIZE_DEFAULT,
                                        ),
                                    title: Text(
                                      place['name'] ?? "--",
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_LARGE,
                                      ),
                                    ),
                                    subtitle: Text(
                                      place['vicinity'] ?? "--",
                                      style: robotoMedium.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_SMALL,
                                      ),
                                    ),
                                    trailing: SvgPicture.asset(
                                      Images.Icon_Right_Arrow,
                                      color: Theme.of(context).primaryColor,
                                      height: 30,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
