// ignore_for_file: deprecated_member_use

// class RamadanScheduleWidget extends StatefulWidget {
//   const RamadanScheduleWidget({super.key});
//
//   @override
//   State<RamadanScheduleWidget> createState() => _RamadanScheduleWidgetState();
// }
//
// class _RamadanScheduleWidgetState extends State<RamadanScheduleWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<TodaysPrayerTimeController>(
//       builder: (todaysPrayerTimeController) {
//         return GetBuilder<PrayerTimeController>(
//           builder: (packagePrayerTimeController) {
//             var isAutomaticPayerTime = Get.find<SettingsController>()
//                     .mosqueSettingsApiData!
//                     .data!
//                     .automaticPayerTime ==
//                 true;
//             return Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: Dimensions.PADDING_SIZE_DEFAULT),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: Dimensions.PADDING_SIZE_DEFAULT),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardColor,
//                       borderRadius:
//                           BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Get.isDarkMode
//                                 ? Colors.grey[800]!
//                                 : Colors.grey[200]!,
//                             spreadRadius: 1,
//                             blurRadius: 5)
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Ramadan icon
//                             SvgPicture.asset(
//                               Images.Icon_Ramadan_Time,
//                               height: 20,
//                               fit: BoxFit.fill,
//                               color: Theme.of(context).primaryColor,
//                             ),
//                             const SizedBox(
//                                 width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//
//                             // Ramadan Schedule
//                             Text(
//                               "ramadan_schedule".tr,
//                               textAlign: TextAlign.center,
//                               style: robotoRegular.copyWith(
//                                 color: Theme.of(context).primaryColor,
//                                 fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(
//                             color:
//                                 Theme.of(context).hintColor.withOpacity(0.5)),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: Dimensions.PADDING_SIZE_SMALL),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Column(
//                                 children: [
//                                   Text(
//                                     "sehri_end".tr,
//                                     style: robotoMedium.copyWith(
//                                         color: Theme.of(context).hintColor),
//                                   ),
//                                   Text(
//                                     isAutomaticPayerTime
//                                         ? translateText(
//                                             packagePrayerTimeController
//                                                 .sehriEndTime.value)
//                                         : translateText(
//                                             todaysPrayerTimeController
//                                                 .todaysPrayerApiData!
//                                                 .data!
//                                                 .sehriEnd
//                                                 .toString()),
//                                     style: robotoMedium.copyWith(
//                                         color: Theme.of(context).hintColor),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 "|",
//                                 style: robotoMedium.copyWith(
//                                     color: Theme.of(context).hintColor),
//                               ),
//                               Column(
//                                 children: [
//                                   FittedBox(
//                                     child: isAutomaticPayerTime
//                                         ? Text(
//                                             packagePrayerTimeController
//                                                     .isFajrTime.value
//                                                 ? "remaining_for_sehri".tr
//                                                 : "remaining_to_iftar".tr,
//                                             style: robotoMedium.copyWith(
//                                                 color: Theme.of(context)
//                                                     .hintColor),
//                                           )
//                                         : Text(
//                                             todaysPrayerTimeController
//                                                     .isFajrTime.value
//                                                 ? "remaining_for_sehri".tr
//                                                 : "remaining_to_iftar".tr,
//                                             style: robotoMedium.copyWith(
//                                                 color: Theme.of(context)
//                                                     .hintColor),
//                                           ),
//                                   ),
//                                   Obx(
//                                     () => isAutomaticPayerTime
//                                         ? Text(
//                                             packagePrayerTimeController
//                                                     .isFajrTime.value
//                                                 ? translateText(
//                                                     "${packagePrayerTimeController.packageTimeRemaining}")
//                                                 : translateText(
//                                                     "${packagePrayerTimeController.packageTimeRemaining}"),
//                                             style: robotoMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_OVER_LARGE,
//                                                 color: Theme.of(context)
//                                                     .hintColor),
//                                           )
//                                         : Text(
//                                             todaysPrayerTimeController
//                                                     .isFajrTime.value
//                                                 ? translateText(
//                                                     "${todaysPrayerTimeController.timeRemaining}")
//                                                 : translateText(
//                                                     "${todaysPrayerTimeController.timeRemaining}"),
//                                             style: robotoMedium.copyWith(
//                                                 fontSize: Dimensions
//                                                     .FONT_SIZE_OVER_LARGE,
//                                                 color: Theme.of(context)
//                                                     .hintColor),
//                                           ),
//                                   ),
//                                 ],
//                               ),
//                               Text(
//                                 "|",
//                                 style: robotoMedium.copyWith(
//                                     color: Theme.of(context).hintColor),
//                               ),
//                               Column(
//                                 children: [
//                                   Text(
//                                     "iftar_start".tr,
//                                     style: robotoMedium.copyWith(
//                                         color: Theme.of(context).hintColor),
//                                   ),
//                                   Text(
//                                     isAutomaticPayerTime
//                                         ? translateText(
//                                             packagePrayerTimeController
//                                                 .maghribStartTime.value)
//                                         : translateText(
//                                             todaysPrayerTimeController
//                                                 .todaysPrayerApiData!
//                                                 .data!
//                                                 .iftarStart
//                                                 .toString()),
//                                     style: robotoMedium.copyWith(
//                                         color: Theme.of(context).hintColor),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
