// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class NearbyMosqueController extends GetxController {
  GlobalKey<FormState> nearbyMosqueFormKey = GlobalKey<FormState>();

  // Get Address Variable =====>
  var location = '';
  double? latitude;
  double? longitude;
  RxString currentAddress = '--'.obs;
  late StreamSubscription<Position> streamSubscription;
  late LocationSettings locationSettings;
  RxBool isLocationDenied = false.obs;

  // local variable
  var userLocation = ''.obs;
  var places = [].obs;
  RxBool isLoading = false.obs;
  List<String> splitKm = [];
  int kmToRadious = 2;

  var km = '2  KM'.obs;

  @override
  void onInit() {
    super.onInit();
    // getLocation();
    loadKmDropdownValue(km.value);
  }

  Future<void> getLocation() async {
    bool serviceEnabled = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If not enabled, prompt user to enable location services
      await Geolocator.openLocationSettings();
      return;
    }

    // Check location permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // If permission is denied, request permission from the user
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //   If permission is still denied, show a message to the user using GetX's Snackbar
        showCustomSnackBar(
          "for_getting_Automatic_Prayer_Time_Nearby_Mosque_Qibla_Compass_need_to_enable_location_permission"
              .tr,
          isError: true,
        );

        await prefs.setBool("isLocationDenied", true);
        bool? storedFontSize = prefs.getBool("isLocationDenied");
        if (storedFontSize != null) {
          isLocationDenied.value = storedFontSize;
        }

        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      // If permission is permanently denied, show a message to the user using GetX's Snackbar
      showCustomSnackBar(
        "for_getting_Automatic_Prayer_Time_Nearby_Mosque_Qibla_Compass_need_to_enable_location_permission"
            .tr,
        isError: true,
        onTap: () => openAppSettings(),
      );

      await prefs.setBool("isLocationDenied", true);
      bool? storedFontSize = prefs.getBool("isLocationDenied");
      if (storedFontSize != null) {
        isLocationDenied.value = storedFontSize;
      }
      return;
    }

    // If permission is granted, retrieve the current position

    if (serviceEnabled) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        userLocation.value = '${position.latitude},${position.longitude}';
        searchNearbyPlaces();
        update();
      } catch (e) {
        await prefs.setBool("isLocationDenied", true);
        bool? storedFontSize = prefs.getBool("isLocationDenied");
        if (storedFontSize != null) {
          isLocationDenied.value = storedFontSize;
        }
        showCustomSnackBar(
          "for_getting_Automatic_Prayer_Time_Nearby_Mosque_Qibla_Compass_need_to_enable_location_permission"
              .tr,
          isError: true,
          onTap: () => openAppSettings(),
        );
      }
    }
  }

  void searchNearbyPlaces() async {
    // print("Call searchNearbyPlaces function");
    // print(AppConstants.MAPS_API_KEY);

    // map api key
    final String apiKey =
        Get.find<SettingsController>()
            .mosqueSettingsApiData!
            .data!
            .googleMapKey ??
        'no api key found';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLocationDenied", false);
    bool? storedFontSize = prefs.getBool("isLocationDenied");
    if (storedFontSize != null) {
      isLocationDenied.value = storedFontSize;
    }
    try {
      isLoading(true);

      debugPrint("Map api key: $apiKey");
      var url =
          '${AppConstants.NEARBY_MOSQUE_URL}/json?location=${userLocation.value}&radius=${1000 * kmToRadious}&type=mosque&key=$apiKey';
      var response = await http.get(Uri.parse(url));
      var decoded = json.decode(response.body);
      places.value = decoded['results'];
    } catch (e) {
        debugPrint("Near By Mosque api Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // search by distance function
  void loadKmDropdownValue(String newValue) async {
    km.value = newValue;
    splitKm = km.split(" ");
    kmToRadious = int.parse(splitKm[0]);
    update();
  }
}
