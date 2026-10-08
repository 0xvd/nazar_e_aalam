// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'package:nazar_e_alam/data/api/api_client.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/data/model/response/todays_prayer_time_model.dart';
// import 'package:nazar_e_alam/util/app_constants.dart';

// class TodaysPrayerTimeController extends GetxController implements GetxService {
//   final ApiClient apiClient;
//   TodaysPrayerTimeController({required this.apiClient});

// // local variable
//   RxBool isprayerTimeLoading = false.obs;
//   TodaysPrayerTimeModel? todaysPrayerApiData;

// // Prayer Time variable ======>
//   RxString fajrJamah = "--".obs;
//   RxString sunriseStart = "--".obs;
//   RxString dhuhrJamah = "--".obs;
//   RxString asrjamah = "--".obs;
//   RxString magribJamah = "--".obs;
//   RxString ishaJamah = "--".obs;
//   RxString currentJamahTime = "--".obs;
//   RxString currentWaqtName = "--".obs;
//   var timeRemaining = '00:00:00'.obs;
//   var isFajrTime = true.obs;
//   late Timer _timer;

//   @override
//   void onClose() {
//     _timer.cancel();
//     super.onClose();
//   }

// // get dua list form here
//   Future<void> fetchTodaysPrayerTimeData() async {
//     try {
//       isprayerTimeLoading(true);

//       // Get the current date and time
//       DateTime currentDate = DateTime.now();

//       // Format the date as "yyyy-MM-dd"
//       String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

//       final response = await apiClient
//           .getData(AppConstants.TODAYS_PRAYER_TIME + formattedDate);

//       if (response.statusCode == 200) {
//         todaysPrayerApiData = TodaysPrayerTimeModel.fromJson(response.body);

//         // current wakt and time show
//         prayerNameAndTimes();

//         todaysPrayerApiData!.data!.sehriEnd == "0.00" ||
//                 todaysPrayerApiData!.data!.iftarStart == "0.00"
//             ? null
//             : updateRemainingTime();
//         // Start a timer to update the remaining time every second
//         todaysPrayerApiData!.data!.sehriEnd == "0.00" ||
//                 todaysPrayerApiData!.data!.iftarStart == "0.00"
//             ? null
//             : _timer = Timer.periodic(
//                 const Duration(seconds: 1), (_) => updateRemainingTime());
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error fetching data: $e");
//       }
//     } finally {
//       isprayerTimeLoading(false);
//       update();
//     }
//   }

// // Get Prayer Owakt Function=====>
//   prayerNameAndTimes() {
// // Get Cuttent Time Variable =====>
//     String currentTime = DateFormat.Hms().format(DateTime.now());
//     // print("========> $currentTime");
//     //18:15:56
//     var finalCurrentTime = DateTime.parse('2000-01-01 $currentTime');
//     var apiwaktTime = todaysPrayerApiData!.data!;
//     if (finalCurrentTime
//         .isBefore(DateTime.parse('2000-01-01 ${apiwaktTime.fajrJamat}:00'))) {
//       currentWaqtName.value = "fajr".tr;
//       currentJamahTime.value = apiwaktTime.fajrJamat.toString();
//     } else if (finalCurrentTime
//         .isBefore(DateTime.parse('2000-01-01 ${apiwaktTime.sunrise}:00'))) {
//       currentWaqtName.value = "sunrise".tr;
//       currentJamahTime.value = apiwaktTime.sunrise.toString();
//     } else if (finalCurrentTime
//         .isBefore(DateTime.parse('2000-01-01 ${apiwaktTime.zuhrJamat}:00'))) {
//       currentWaqtName.value =
//           apiwaktTime.isJumma == true ? "jumuah".tr : "dhuhr".tr;
//       currentJamahTime.value = apiwaktTime.zuhrJamat.toString();
//     } else if (finalCurrentTime
//         .isBefore(DateTime.parse('2000-01-01 ${apiwaktTime.asrJamat}:00'))) {
//       currentWaqtName.value = "asr".tr;
//       currentJamahTime.value = apiwaktTime.asrJamat.toString();
//     } else if (finalCurrentTime
//         .isBefore(DateTime.parse('2000-01-01 ${apiwaktTime.maghribAzan}:00'))) {
//       currentWaqtName.value = "magrib".tr;
//       currentJamahTime.value = apiwaktTime.maghribJamat.toString();
//     } else if (finalCurrentTime
//         .isBefore(DateTime.parse('2000-01-01 ${apiwaktTime.ishaJamat}:00'))) {
//       currentWaqtName.value = "isha".tr;
//       currentJamahTime.value = apiwaktTime.ishaJamat.toString();
//     } else if (finalCurrentTime
//         .isAfter(DateTime.parse('2000-01-01 ${apiwaktTime.fajrAzan}:00'))) {
//       currentWaqtName.value = "fajr".tr;
//       currentJamahTime.value = apiwaktTime.fajrJamat.toString();
//     }
//   }

// // count down section ====>
//   void updateRemainingTime() {
//     var sehriEndTime = todaysPrayerApiData!.data!.sehriEnd!.obs;
//     var iftarStartTime = todaysPrayerApiData!.data!.iftarStart!.obs;
//     Duration remainingDuration;
//     DateTime now = DateTime.now();

//     DateTime sehri;
//     DateTime iftar;

//     try {
//       List<String> sehriEndParts = sehriEndTime.value.split(':');
//       List<String> iftarStartParts = iftarStartTime.value.split(':');

//       sehri = DateTime(now.year, now.month, now.day,
//           int.parse(sehriEndParts[0]), int.parse(sehriEndParts[1]));
//       iftar = DateTime(now.year, now.month, now.day,
//           int.parse(iftarStartParts[0]), int.parse(iftarStartParts[1]));
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error parsing time: $e');
//       }
//       return;
//     }

//     if (now.isBefore(sehri)) {
//       remainingDuration = sehri.difference(now);
//       isFajrTime.value = true;
//     } else if (now.isBefore(iftar)) {
//       remainingDuration = iftar.difference(now);
//       isFajrTime.value = false;
//     } else {
//       // Iftar time is over, count down to Fajr time of the next day
//       DateTime nextFajr = sehri.add(const Duration(days: 1));
//       remainingDuration = nextFajr.difference(now);
//       isFajrTime.value = true;
//     }

//     String hours =
//         remainingDuration.inHours.remainder(24).toString().padLeft(2, '0');
//     String minutes =
//         remainingDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     String seconds =
//         remainingDuration.inSeconds.remainder(60).toString().padLeft(2, '0');

//     timeRemaining.value = '$hours:$minutes:$seconds';
//   }
// }
