// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nazar_e_alam/controller/localization_controller.dart';
import 'package:nazar_e_alam/helper/adhan_notification_service_helper.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/screens/notification/widgets/audio_select_widget.dart';
import 'package:nazar_e_alam/view/screens/notification/widgets/salat_waqt.dart';
import 'package:nazar_e_alam/view/screens/notification/widgets/salat_waqt_repository.dart';

class NofificationDWWidget extends StatefulWidget {
  const NofificationDWWidget({super.key});

  @override
  State<NofificationDWWidget> createState() => _NofificationDWWidgetState();
}

class _NofificationDWWidgetState extends State<NofificationDWWidget> {
  late final SalatWaqtRepository _salatWaqtRepository;
  late final AdhanNotificationService _adhanNotificationService;

  List<SalatWaqt> salatList = [];

  @override
  void initState() {
    super.initState();
    _salatWaqtRepository = SalatWaqtRepository();
    _adhanNotificationService = AdhanNotificationServiceImpl();
    getSalatList();
    getNotification();
  }

  bool switchValue = false;

  Future<void> getSalatList() async {
    salatList = await _salatWaqtRepository.getSalatWaqtList();
    setState(() {});
  }

  List<PendingNotificationRequest> pendingList = [];
  List<ActiveNotification> activeList = [];

  Future<void> getNotification() async {
    pendingList = await _adhanNotificationService.getPendingNotifications();
    activeList = await _adhanNotificationService.getActiveNotifications();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizationController) {
        return ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
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
                        Images.Icon_Noti_Settings,
                        width: 25,
                        height: 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                      Text(
                        "notification_settings".tr,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'battery_optimize_message'.tr,
                        style: robotoMedium.copyWith(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'go_to_settings_page_message'.tr,
                        style: robotoMedium.copyWith(),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(salatList.length, (index) {
                    final salat = salatList[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).cardColor,
                      shadowColor: Get.isDarkMode
                          ? Colors.grey[800]!
                          : Colors.grey[200]!,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.RADIUS_DEFAULT,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: Dimensions.PADDING_SIZE_DEFAULT,
                              ),
                              Text(
                                salat.name.toLowerCase().tr,
                                style: robotoMedium,
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
                            value: salat.isNotificationEnabled,
                            onChanged: (value) async {
                              salat.isNotificationEnabled = value;
                              await _salatWaqtRepository.saveSalatWaqt(salat);
                              if (value) {
                                await _adhanNotificationService
                                    .scheduleNotification(
                                      id: salat.id,
                                      title: salat.name.tr,
                                      body:
                                          '${'time_for'.tr} ${salat.name} ${'started_at'.tr} ${DateFormat.jm().format(salat.time)}',
                                      dateTime: salat.time,
                                      payload: salat.time.toIso8601String(),
                                    );
                              } else {
                                await _adhanNotificationService
                                    .cancelNotification(salat.id);
                              }
                              await getSalatList();
                              await getNotification();
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const NotificationSoundSelector(),
              ],
            ),
          ),
        );
      },
    );
  }
}
