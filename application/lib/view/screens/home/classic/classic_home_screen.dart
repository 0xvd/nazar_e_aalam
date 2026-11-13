// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/internet_check_controller.dart';
import 'package:nazar_e_alam/controller/prayer_time_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/controller/theme_controller.dart';
import 'package:nazar_e_alam/helper/date_converter.dart';
import 'package:nazar_e_alam/helper/time_adjustment_helper.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/feature_grid.dart';
import 'package:nazar_e_alam/view/screens/home/classic/widget/bannder_widget.dart';
import 'package:nazar_e_alam/view/screens/home/classic/widget/today_prayer_list_item.dart';

/// Classic home: saffron app bar with location, banner, today's prayer
/// grid, then every feature as grouped cards. Presentational only; data
/// loading is done once by HomeScreen.
///
/// Vertical rhythm: 12 under the app bar, 16 between sections,
/// 12 between prayer rows, 24 before the feature grid.
class ClassicHomeScreen extends StatelessWidget {
  const ClassicHomeScreen({super.key});

  static const double _rowGap = 12;

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
                  : _buildAppBar(context, prayerTimeController),
              body: SafeArea(
                top: false,
                child: isLoading || (mosqueData == null && !hasInternet)
                    ? const DashbordShimmerScreen()
                    : _buildBody(context, prayerTimeController),
              ),
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

  // ───────────── App bar ─────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    PrayerTimeController prayerTimeController,
  ) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final fg = dark ? const Color(0xFFFFF4E8) : Colors.white;
    final accent = dark ? theme.primaryColor : Colors.white;

    return AppBar(
      backgroundColor: dark ? theme.cardColor : theme.primaryColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      title: Row(
        children: [
          const Icon(Icons.location_on_rounded, size: 19, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              prayerTimeController.isManualPrayerTime.value &&
                      prayerTimeController.saveLocalStoreCity?.isNotEmpty ==
                          true
                  ? prayerTimeController.saveLocalStoreCity!
                  : prayerTimeController.currentAddressFull.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'light_or_dark_mode'.tr,
          icon: SvgPicture.asset(
            dark ? Images.Icon_day_mode : Images.Icon_dark_mode,
            height: 25,
            colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
          ),
          onPressed: () => Get.find<ThemeController>().toggleTheme(),
        ),
      ],
    );
  }

  // ───────────── Body ─────────────

  Widget _buildBody(
    BuildContext context,
    PrayerTimeController prayerTimeController,
  ) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breathing room under the rounded app bar.
          const SizedBox(height: 12),
          const BannerWidget(),
          const SizedBox(height: 16),
          _buildPrayerTimesSection(),
          const SizedBox(height: 24),
          const FeatureGrid(modern: false, bottomPadding: 24),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection() {
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
              const SizedBox(height: 12),
              _buildPrayerTimesGrid(prayerData, is24HourFormat),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerTimesHeader(PrayerTimeController controller) {
    return Obx(
      () => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "${"todays_Prayer_Time_in".tr} ${controller.saveAddress.value.isNotEmpty ? controller.saveAddress.value : controller.currentAddressFull.value}",
              style: robotoBold.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
                color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesGrid(dynamic prayerData, bool is24HourFormat) {
    final showRamadan =
        Get.find<SettingsController>()
            .mosqueSettingsApiData
            ?.data
            ?.ramadanSchedule ==
        true;

    String ramadanTime(String? t) =>
        (t == null || t == "0:00" || t == "00:00") ? "0.00" : t;

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
        const SizedBox(height: _rowGap),
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
        const SizedBox(height: _rowGap),
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
        if (showRamadan) ...[
          const SizedBox(height: _rowGap),
          _buildPrayerRow(
            leftPrayer: _buildPrayerCard(
              icon: Images.sehri,
              name: 'Sehri'.tr,
              prayerKey: 'sehri',
              time: ramadanTime(prayerData?.sehriEnd),
              is24HourFormat: is24HourFormat,
            ),
            rightPrayer: _buildPrayerCard(
              icon: Images.ifter,
              name: 'Iftar'.tr,
              prayerKey: 'iftar',
              time: ramadanTime(prayerData?.iftarStart),
              is24HourFormat: is24HourFormat,
            ),
          ),
        ],
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
          const SizedBox(width: _rowGap),
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
        final canAdjust = prayerKey != null && !isManual;

        // Don't apply adjustment if manual prayer times are active
        final adjustedTime = canAdjust
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
          isAdjusted: canAdjust
              ? TimeAdjustmentHelper().isTimeAdjusted(prayerKey)
              : false,
          adjustmentText: canAdjust
              ? TimeAdjustmentHelper().getAdjustmentText(prayerKey)
              : '',
        );
      },
    );
  }
}
