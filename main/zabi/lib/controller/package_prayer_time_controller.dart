// ignore_for_file: avoid_print, deprecated_member_use, strict_top_level_inference

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/data/model/response/city_model.dart';
import 'package:nazar_e_alam/data/model/response/todays_prayer_time_model.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class PrayerTimeController extends GetxController implements GetxService {
  final ApiClient apiClient;
  PrayerTimeController({required this.apiClient});

  // local variable
  RxBool isprayerTimeLoading = false.obs;
  PrayerTimeModel? prayerTimeModel;

  // Prayer Time
  TextEditingController citySearchController = TextEditingController();
  final RxString search = ''.obs;

  RxString fajrStart = "--".obs;
  RxString sunriseStart = "--".obs;
  RxString dhuhrStart = "--".obs;
  RxString asrStart = "--".obs;
  RxString magribStart = "--".obs;
  RxString ishaStart = "--".obs;
  RxString currentWaktTime = "--".obs;
  RxString currentWaqtName = "--".obs;

  RxString currentAddress = '--'.obs;
  RxString saveAddress = '--'.obs;
  RxBool isLocationDenied = false.obs;

  RxBool isPrayerTimes = false.obs;
  double? latitude;
  double? longitude;
  String? saveLocalStoreCity;

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

        List<Placemark> addressList = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final callAddress = addressList.first;
        currentAddress.value = Platform.isIOS
            ? callAddress.administrativeArea!
            : callAddress.subAdministrativeArea!;

        final prefs = await SharedPreferences.getInstance();
        final isPrayerTme = prefs.getBool(AppConstants.isPrayerTme);
        bool isTimeTrue = prefs.getBool(AppConstants.isPrayerTme) ?? false;

        isPrayerTimes.value = isTimeTrue;
        debugPrint("isTimeTrue: ${isPrayerTimes.value}");

        final saveCityName = prefs.getString(AppConstants.saveCityName);

        fetchPrayerTime(
          reload: false,
          isManualPrayerTme: isPrayerTme ?? false,
          manualCity: saveCityName ?? currentAddress.toString(),
        );

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

  // Calculation Methods
  final List<Map<String, String>> _calculationMethod = [
    {'id': '0', 'value': 'JAFARI'},
    {'id': '1', 'value': 'KARACHI'},
    {'id': '2', 'value': 'ISNA'},
    {'id': '3', 'value': 'MWL'},
    {'id': '4', 'value': 'MAKKAH'},
    {'id': '5', 'value': 'EGYPT'},
    {'id': '7', 'value': 'TEHRAN'},
    {'id': '8', 'value': 'GULF'},
    {'id': '9', 'value': 'KUWAIT'},
    {'id': '10', 'value': 'QATAR'},
    {'id': '11', 'value': 'SINGAPORE'},
    {'id': '12', 'value': 'FRANCE'},
    {'id': '13', 'value': 'TURKEY'},
    {'id': '14', 'value': 'RUSSIA'},
    {'id': '15', 'value': 'MOONSIGHTING'},
    {'id': '16', 'value': 'DUBAI'},
    {'id': '17', 'value': 'JAKIM'},
    {'id': '18', 'value': 'TUNISIA'},
    {'id': '19', 'value': 'ALGERIA'},
    {'id': '20', 'value': 'KEMENAG'},
    {'id': '21', 'value': 'MOROCCO'},
    {'id': '22', 'value': 'PORTUGAL'},
    {'id': '23', 'value': 'JORDAN'},
  ];

  List<Map<String, String>> get calculationMethod => _calculationMethod;
  String? _selectedCalculationMethod;
  String? get selectedCalculationMethod => _selectedCalculationMethod;

  // Madhab List
  final List<Map<String, String>> _prayerMadhabList = [
    {'id': 'STANDARD', 'value': 'STANDARD'},
    {'id': 'HANAFI', 'value': 'HANAFI'},
  ];

  List<Map<String, String>> get prayerMadhabList => _prayerMadhabList;

  String? _selectedPrayerMadhab;
  String? get selectedPrayerMadhab => _selectedPrayerMadhab;

  /// Load the settings from local storage or set default values.
  Future<void> loadPrayerTimeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isManualPrayerTime.value =
        prefs.getBool(AppConstants.IS_MANUAL_PRAYER_TIME) ?? false;

    // Load Calculation Method
    String? savedMethod = prefs.getString('selectedCalculationMethod');
    if (savedMethod == null) {
      Map<String, String> defaultMethod = {'id': '1', 'value': 'KARACHI'};
      await prefs.setString('selectedCalculationMethod', defaultMethod['id']!);
      _selectedCalculationMethod = defaultMethod['id'];
    } else {
      _selectedCalculationMethod = savedMethod;
    }

    // Load Prayer Madhab
    String? savedMadhab = prefs.getString('selectedPrayerMadhab');
    if (savedMadhab == null) {
      Map<String, String> defaultMadhab = {
        'id': 'STANDARD',
        'value': 'STANDARD',
      };
      await prefs.setString('selectedPrayerMadhab', defaultMadhab['id']!);
      _selectedPrayerMadhab = defaultMadhab['id'];
    } else {
      _selectedPrayerMadhab = savedMadhab;
    }

    update();
  }

  /// Set a new calculation method and save it in local storage.
  Future<void> setSelectedCalculationMethod(String? value) async {
    if (value != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCalculationMethod', value);
      _selectedCalculationMethod = value;
      update();
    }
  }

  /// Set a new prayer Madhab and save it in local storage.
  Future<void> setSelectedPrayerMadhab(String? value) async {
    if (value != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedPrayerMadhab', value);
      _selectedPrayerMadhab = value;
      update();
    }
  }

  var isManualPrayerTime = false.obs;
  bool _isFetchingPrayerTime = false;

  // get dua list form here
  Future<void> fetchPrayerTime({
    bool reload = true,
    bool isManualPrayerTme = false,
    String? manualCity,
  }) async {

    if (_isFetchingPrayerTime) {
      if (kDebugMode) {
        print("Prayer time request already running, skipping...");
      }
      return;
    }

    _isFetchingPrayerTime = true;

    try {
      await loadPrayerTimeSettings();
      reload ? isprayerTimeLoading(true) : isprayerTimeLoading(false);

      // Store the prayer time type
      isManualPrayerTime.value = isManualPrayerTme;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save the prayer time type to SharedPreferences
      await prefs.setBool(
        AppConstants.IS_MANUAL_PRAYER_TIME,
        isManualPrayerTme,
      );

      saveLocalStoreCity = prefs.getString(AppConstants.saveCityName);
      saveAddress.value = prefs.getString(AppConstants.saveCityName) ?? "";
      List<Placemark> addressList = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final callAddress = addressList.first;
      currentAddress.value = Platform.isIOS
          ? callAddress.administrativeArea!
          : callAddress.subAdministrativeArea!;
      if (kDebugMode) {
        print("Address: ${currentAddress.value}");
      }
      // Get the current date and time
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      var lat = position.latitude;
      var lng = position.longitude;
      var prayerMethod = _selectedCalculationMethod;
      var school = _selectedPrayerMadhab;
      var timezone = await FlutterTimezone.getLocalTimezone();

      final response = await apiClient
          .postData(AppConstants.TODAYS_PRAYER_TIME, {
            "type": isManualPrayerTme ? "manual" : "automatic",
            "date": formattedDate,
            "city": isManualPrayerTme ? manualCity ?? "" : currentAddress.value,
            "lat": "$lat",
            "lng": "$lng",
            "prayer_method": "$prayerMethod",
            "school": "$school",
            "timezone": timezone,
          });
      update();
      if (response.statusCode == 200) {
        prayerTimeModel = PrayerTimeModel.fromJson(response.body);
        // current wakt and time show
        prayerNameAndTimes();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isprayerTimeLoading(false);
      update();
    }
  }

  // Get Prayer Owakt Function
  prayerNameAndTimes() {
    // Get Cuttent Time Variable =====>
    String currentTime = DateFormat.Hms().format(DateTime.now());
    // print("currentTime========> $currentTime");
    //18:15:56
    var finalCurrentTime = DateTime.parse('2000-01-01 $currentTime');
    var apiwaktTime = prayerTimeModel!.data!;
    if (finalCurrentTime.isBefore(
      DateTime.parse('2000-01-01 ${apiwaktTime.fajrStart}:00'),
    )) {
      currentWaqtName.value = "fajr".tr;
      currentWaktTime.value = apiwaktTime.fajrStart.toString();
    } else if (finalCurrentTime.isBefore(
      DateTime.parse('2000-01-01 ${apiwaktTime.sunrise}:00'),
    )) {
      currentWaqtName.value = "sunrise".tr;
      currentWaktTime.value = apiwaktTime.sunrise.toString();
    } else if (finalCurrentTime.isBefore(
      DateTime.parse('2000-01-01 ${apiwaktTime.zuhrStart}:00'),
    )) {
      currentWaqtName.value = DateTime.now().weekday == DateTime.friday
          ? "jumuah".tr
          : "dhuhr".tr;
      currentWaktTime.value = apiwaktTime.zuhrStart.toString();
    } else if (finalCurrentTime.isBefore(
      DateTime.parse('2000-01-01 ${apiwaktTime.asrStart}:00'),
    )) {
      currentWaqtName.value = "asr".tr;
      currentWaktTime.value = apiwaktTime.asrStart.toString();
    } else if (finalCurrentTime.isBefore(
      DateTime.parse('2000-01-01 ${apiwaktTime.maghribStart}:00'),
    )) {
      currentWaqtName.value = "magrib".tr;
      currentWaktTime.value = apiwaktTime.maghribStart.toString();
    } else if (finalCurrentTime.isBefore(
      DateTime.parse('2000-01-01 ${apiwaktTime.ishaStart}:00'),
    )) {
      currentWaqtName.value = "isha".tr;
      currentWaktTime.value = apiwaktTime.ishaStart.toString();
    } else if (finalCurrentTime.isAfter(
      DateTime.parse('2000-01-01 ${apiwaktTime.fajrStart}:00'),
    )) {
      currentWaqtName.value = "fajr".tr;
      currentWaktTime.value = apiwaktTime.fajrStart.toString();
    }
  }

  RxBool isCityListLoading = false.obs;
  CityesModel? cityModelData;

  Future<void> cityCategoryListData() async {
    try {
      isCityListLoading(true);
      update();

      final response = await apiClient.getData(AppConstants.CITY_LIST);

      if (response.statusCode == 200) {
        cityModelData = CityesModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isCityListLoading(false);
      update();
    }
  }

  // 12 or 24 hour format

  RxBool is24HourFormat = true.obs;

  Future<void> loadSwitchValue() async {
    final prefs = await SharedPreferences.getInstance();
    is24HourFormat.value = prefs.getBool('is24HrFormat') ?? true;
  }

  Future<void> updateSwitchValue(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is24HrFormat', value);
    is24HourFormat.value = value;
  }
}
