// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/controller/package_prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/date_converter.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/helper/time_adjustment_helper.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
// import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
// import 'package:nazar_e_alam/view/screens/ai_islamic_assistant/ai_islamic_assistant.dart';
import 'package:nazar_e_alam/view/screens/home/classic/widget/bannder_widget.dart';
import 'package:nazar_e_alam/view/screens/home/classic/widget/feature_item_widget.dart';
import 'package:nazar_e_alam/view/screens/home/classic/widget/today_prayer_list_item.dart';

/// The original ("Classic") home screen design. This widget is purely
/// presentational — all data bootstrapping (location, prayer times, mosque
/// settings) is handled once by the [HomeScreen] router above it.
class ClassicHomeScreen extends StatelessWidget {
  const ClassicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hasInternet = Get.find<InternetController>().hasInternet.value;
    return GetBuilder<SettingsController>(
      builder: (settingsController) {
        return GetBuilder<PrayerTimeController>(
          builder: (prayerTimeController) {
            final isLoading = _isLoadingState(
              settingsController,
              prayerTimeController,
            );
            final mosqueData = settingsController.mosqueSettingsApiData?.data;

            return Scaffold(
              appBar: isLoading || mosqueData == null
                  ? null
                  : _buildAppBar(context, mosqueData, prayerTimeController),
              body: SafeArea(
                top: false,
                child: isLoading || mosqueData == null && !hasInternet
                    ? const DashbordShimmerScreen()
                    : _buildBody(context, mosqueData, prayerTimeController),
              ),

              // floatingActionButton: GestureDetector(
              //   onTap: () {
              //     Get.to(() => const AiIslamicAssistantScreen());
              //   },
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(30),
              //     child: BackdropFilter(
              //       filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 5,
              //           vertical: 8,
              //         ),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(30),
              //           gradient: LinearGradient(
              //             colors: [
              //               Theme.of(context).primaryColor.withOpacity(0.35),
              //               Theme.of(context).primaryColor.withOpacity(0.08),
              //             ],
              //             begin: Alignment.topLeft,
              //             end: Alignment.bottomRight,
              //           ),
              //           border: Border.all(
              //             color: Theme.of(
              //               context,
              //             ).primaryColor.withOpacity(0.5),
              //             width: 1,
              //           ),
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.15),
              //               blurRadius: 12,
              //               offset: const Offset(0, 6),
              //             ),
              //           ],
              //         ),
              //         child: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Container(
              //               padding: const EdgeInsets.symmetric(
              //                 horizontal: 5,
              //                 vertical: 2,
              //               ),
              //               decoration: BoxDecoration(
              //                 shape: BoxShape.circle,
              //                 color: AppColor.cardColor,
              //               ),
              //               child: Image.asset(
              //                 Images.aiAssistant,
              //                 width: 30,
              //                 height: 30,
              //               ),
              //             ),
              //             const SizedBox(width: 2),
              //             Text(
              //               "${"ask_ai_key".tr} ",
              //               style: robotoRegular.copyWith(
              //                 color: Get.isDarkMode
              //                     ? AppColor.cardColor
              //                     : AppColor.primaryColor,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            );
          },
        );
      },
    );
  }

  bool _isLoadingState(
    SettingsController settingsController,
    PrayerTimeController prayerTimeController,
  ) {
    return settingsController.isMosqueSettingsLoading.value ||
        prayerTimeController.isprayerTimeLoading.value ||
        settingsController.mosqueSettingsApiData == null;
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    dynamic mosqueData,
    PrayerTimeController prayerTimeController,
  ) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return AppBar(
      backgroundColor: isDark ? theme.cardColor : theme.primaryColor,
      // backgroundColor: Color(0xFFfcffe3),
      elevation: 0,
      centerTitle: false,
      title: _buildAppBarTitle(context, mosqueData, prayerTimeController),
      actions: _buildAppBarActions(context, mosqueData, isDark, theme),
    );
  }

  Widget _buildAppBarTitle(
    BuildContext context,
    dynamic mosqueData,
    PrayerTimeController prayerTimeController,
  ) {
    final theme = Theme.of(context);
    // final isDark = Get.isDarkMode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   mosqueData.mosqueName.toString(),
        //   style: robotoRegular.copyWith(
        //     fontSize: Dimensions.FONT_SIZE_OVER_LARGE + 2,
        //     color: isDark ? null : theme.cardColor,
        //   ),
        // ),
        Row(
          children: [
            SvgPicture.asset(
              Images.Icon_Location,
              height: 14,
              fit: BoxFit.fill,
              color: theme.hintColor,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                prayerTimeController.saveLocalStoreCity ??
                    prayerTimeController.currentAddress.toString(),
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.FONT_SIZE_DEFAULT,
                  color: theme.hintColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    dynamic mosqueData,
    bool isDark,
    ThemeData theme,
  ) {
    return [
      if (mosqueData.showBannerIcon == true)
        IconButton(
          onPressed: () => Get.toNamed(RouteHelper.donationTypeList),
          icon: SvgPicture.asset(
            Images.Icon_Donated,
            height: 28,
            fit: BoxFit.fill,
            color: isDark ? theme.primaryColor : theme.cardColor,
          ),
        ),
      IconButton(
        tooltip: "light_or_dark_mode".tr,
        icon: SvgPicture.asset(
          isDark ? Images.Icon_day_mode : Images.Icon_dark_mode,
          height: 25,
          fit: BoxFit.fill,
          color: isDark ? theme.primaryColor : theme.cardColor,
        ),
        onPressed: () => Get.find<ThemeController>().toggleTheme(),
      ),
    ];
  }

  Widget _buildBody(
    BuildContext context,
    dynamic mosqueData,
    PrayerTimeController prayerTimeController,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerWidget(),
          const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          _buildPrayerTimesSection(prayerTimeController),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
          if (mosqueData.showDonationBanner == true)
            _buildDonationBanner(context, mosqueData),
          _buildFeaturesGrid(context),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT * 3),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection(PrayerTimeController prayerTimeController) {
    return GetBuilder<PrayerTimeController>(
      builder: (controller) {
        final is24HourFormat = controller.is24HourFormat.value;
        final prayerData = controller.prayerTimeModel?.data;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrayerTimesHeader(controller),
              const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              _buildPrayerTimesGrid(prayerData, is24HourFormat),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimesHeader(PrayerTimeController controller) {
    return Obx(
      () => Text(
        "${"todays_Prayer_Time_in".tr} ${controller.saveAddress.value.isNotEmpty ? controller.saveAddress.value : controller.currentAddress.value}",
        textAlign: TextAlign.left,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.FONT_SIZE_LARGE,
          fontWeight: FontWeight.bold,
          color: Theme.of(Get.context!).primaryColor,
        ),
      ),
    );
  }

  Widget _buildPrayerTimesGrid(dynamic prayerData, bool is24HourFormat) {
    return Column(
      children: [
        _buildPrayerRow(
          leftPrayer: _buildPrayerCard(
            icon: Images.Icon_Fajr,
            name: 'fajr'.tr,
            prayerKey: 'fajr',
            time: prayerData?.fajrStart ?? "00:00",
            is24HourFormat: is24HourFormat,
          ),
          rightPrayer: _buildPrayerCard(
            icon: Images.Sunrise,
            name: 'sunrise'.tr,
            time: prayerData?.sunrise ?? "00:00",
            is24HourFormat: is24HourFormat,
            isSunrise: true,
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
        _buildPrayerRow(
          leftPrayer: _buildPrayerCard(
            icon: Images.Icon_Dhuhr,
            name: prayerData?.isJumma == true ? 'jumuah'.tr : 'dhuhr'.tr,
            prayerKey: 'zuhr',
            time: prayerData?.zuhrStart ?? "00:00",
            is24HourFormat: is24HourFormat,
          ),
          rightPrayer: _buildPrayerCard(
            icon: Images.Icon_Asr,
            name: 'asr'.tr,
            prayerKey: 'asr',
            time: prayerData?.asrStart ?? "00:00",
            is24HourFormat: is24HourFormat,
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
        _buildPrayerRow(
          leftPrayer: _buildPrayerCard(
            icon: Images.Icon_Maghrib,
            name: 'magrib'.tr,
            prayerKey: 'maghrib',
            time: prayerData?.maghribStart ?? "00:00",
            is24HourFormat: is24HourFormat,
          ),
          rightPrayer: _buildPrayerCard(
            icon: Images.Icon_Isha,
            name: 'isha'.tr,
            prayerKey: 'isha',
            time: prayerData?.ishaStart ?? "00:00",
            is24HourFormat: is24HourFormat,
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
        if (Get.find<SettingsController>()
                .mosqueSettingsApiData
                ?.data
                ?.ramadanSchedule ==
            true)
          _buildPrayerRow(
            leftPrayer: _buildPrayerCard(
              icon: Images.sehri,
              name: 'Sehri'.tr,
              prayerKey: 'sehri',
              time:
                  prayerData?.sehriEnd == "0:00" ||
                      prayerData?.sehriEnd == null ||
                      prayerData?.sehriEnd == "00:00"
                  ? "0.00"
                  : prayerData?.sehriEnd ?? "0.00",
              is24HourFormat: is24HourFormat,
            ),
            rightPrayer: _buildPrayerCard(
              icon: Images.ifter,
              name: 'Iftar'.tr,
              prayerKey: 'iftar',
              time:
                  prayerData?.iftarStart == "0:00" ||
                      prayerData?.iftarStart == null ||
                      prayerData?.iftarStart == "00:00"
                  ? "0.00"
                  : prayerData?.iftarStart ?? "0.00",
              is24HourFormat: is24HourFormat,
            ),
          ),
      ],
    );
  }

  Widget _buildPrayerRow({
    required Widget leftPrayer,
    required Widget rightPrayer,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leftPrayer,
          const SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
          rightPrayer,
        ],
      ),
    );
  }

  Widget _buildPrayerCard({
    required String icon,
    required String name,
    required String time,
    required bool is24HourFormat,
    String? prayerKey,
    bool isSunrise = false,
  }) {
    return GetBuilder<PrayerTimeController>(
      builder: (prayerController) {
        final isManual = prayerController.isManualPrayerTime.value;

        // Don't apply adjustment if manual prayer times are active
        final adjustedTime = (prayerKey != null && !isManual)
            ? TimeAdjustmentHelper().getDisplayTime(
                prayerKey: prayerKey,
                defaultTime: time,
              )
            : time;

        final displayTime = translateText(
          DateConverter.formatPrayerTime(adjustedTime, is24HourFormat),
        );

        return TodaysprayerWidget(
          iconImage: icon,
          prayerName: name,
          adhan: displayTime,
          jamah: displayTime,
          isSunrise: isSunrise,
          sunriseStart: isSunrise ? displayTime : "00:00",
          isAdjusted: (prayerKey != null && !isManual)
              ? TimeAdjustmentHelper().isTimeAdjusted(prayerKey)
              : false,
          adjustmentText: (prayerKey != null && !isManual)
              ? TimeAdjustmentHelper().getAdjustmentText(prayerKey)
              : '',
        );
      },
    );
  }

  Widget _buildDonationBanner(BuildContext context, dynamic mosqueData) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_DEFAULT,
          ),
          child: GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.donationTypeList),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                boxShadow: [
                  BoxShadow(
                    color: Get.isDarkMode
                        ? Colors.grey[850]!
                        : Colors.grey[200]!,
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(mosqueData.donationBanner.toString()),
                  fit: BoxFit.fitWidth,
                  onError: (_, _) => const AssetImage(Images.Donate_Now),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),
      ],
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_DEFAULT,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.PADDING_SIZE_DEFAULT,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_GRID_SMALL,
          ),
          child: GridView.count(
            shrinkWrap: true,
            primary: false,
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            addAutomaticKeepAlives: false,
            children: _buildFeatureItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureItems() {
    return [
      _buildFeatureItem(
        name: "audio_quran".tr,
        iconPath: Images.Iocn_Audio,
        route: RouteHelper.recters,
      ),
      _buildFeatureItem(
        name: "hadith".tr,
        iconPath: Images.Icon_Hadith,
        route: RouteHelper.hadithBookName,
      ),
      _buildFeatureItem(
        name: "allah_name".tr,
        iconPath: Images.Icon_Allah_99_name,
        route: RouteHelper.sifatName,
      ),
      _buildFeatureItem(
        name: "dua".tr,
        iconPath: Images.Icon_Dua,
        route: RouteHelper.dua,
      ),
      _buildFeatureItem(
        name: "dikir".tr,
        iconPath: Images.Icon_Dikir,
        route: RouteHelper.dhikr,
      ),
      _buildFeatureItem(
        name: "wallpapers_key".tr,
        iconPath: Images.wallpaper,
        route: RouteHelper.wallpaperScreens,
      ),
      // _buildFeatureItem(
      //   name: "ai_name_key".tr,
      //   iconPath: Images.nameGenerator,
      //   route: RouteHelper.aiNameGenerator,
      // ),
      _buildFeatureItem(
        name: "alphabet_key".tr,
        iconPath: Images.Icon_Alif,
        route: RouteHelper.alphabetScreens,
      ),
    ];
  }

  Widget _buildFeatureItem({
    required String name,
    required String iconPath,
    required String route,
  }) {
    return FeatureItemWidget(
      itemName: name,
      itemIconPath: iconPath,
      onPressed: () => Get.toNamed(route),
    );
  }
}
