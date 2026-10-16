// ignore_for_file: deprecated_member_use

import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:nazar_e_alam/data/model/response/local_dhikr_model.dart';
import 'package:nazar_e_alam/helper/translator_helper.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/loading_indicator.dart';
import 'package:nazar_e_alam/controller/dhikr_controller.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/images.dart';
import '../../../../util/styles.dart';

class LocalDhikrCountScreen extends StatefulWidget {
  final bool appBackButton;
  const LocalDhikrCountScreen({super.key, required this.appBackButton});

  @override
  State<LocalDhikrCountScreen> createState() => _LocalDhikrCountScreenState();
}

class _LocalDhikrCountScreenState extends State<LocalDhikrCountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    // Add a listener to rebuild the widget on each animation tick
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final DhikrController localDhikrController =
      Get.put(DhikrController(dhikrRepo: Get.find()));

  @override
  Widget build(BuildContext context) {
    var dhikrId = localDhikrController.localDhikrId.toString();
    final LocalDhikrModel? dhikr =
        localDhikrController.dhikrList.firstWhereOrNull((d) => d.id == dhikrId);

    if (dhikr == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "--",
          isBackButtonExist: widget.appBackButton == true ? true : false,
        ),
        body: Center(
          child: Text(
            'dhikr_not_found_with_iD: $dhikrId'.tr,
            style: robotoMedium,
          ),
        ),
      );
    }
    return GetBuilder<DhikrController>(
      builder: (localDhikrController) {
        localDhikrController
            .localLoadCount(localDhikrController.localDhikrId.toString());
        return Scaffold(
          // Appbar start ===>
          appBar: CustomAppBar(
            title: dhikr.englishName,
            isBackButtonExist: widget.appBackButton == true ? true : false,
          ),

          // body start ===>
          body: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_DEFAULT),
            child: localDhikrController.dhikrList.isEmpty
                ? const Center(
                    child: LoadingIndicator(),
                  )
                : Column(
                    children: [
                      // Arabic and English Dhikr name and discription section---->
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical:
                                            Dimensions.PADDING_SIZE_SMALL),
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: SvgPicture.asset(
                                        Images.Bismillah,
                                        height: 60,
                                        fit: BoxFit.fitHeight,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  Text(
                                    "arabic".tr,
                                    textAlign: TextAlign.start,
                                    style: robotoMedium.copyWith(
                                      fontSize:
                                          Dimensions.FONT_SIZE_EXTRA_LARGE,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dhikr.arabicName == ""
                                        ? "--"
                                        : dhikr.arabicDescription,
                                    textAlign: TextAlign.justify,
                                    style: Get.find<SettingsController>()
                                        .selectedArabicFont
                                        .copyWith(
                                      fontSize: Get.find<SettingsController>()
                                          .arabicFontSize
                                          .value,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                  const Divider(),
                                  Text(
                                    "english".tr,
                                    textAlign: TextAlign.justify,
                                    style: robotoMedium.copyWith(
                                      fontSize:
                                          Dimensions.FONT_SIZE_EXTRA_LARGE,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dhikr.englishDescription == ""
                                        ? "--"
                                        : dhikr.englishDescription,
                                    textAlign: TextAlign.justify,
                                    style: robotoMedium.copyWith(
                                      fontSize:
                                          Dimensions.FONT_SIZE_EXTRA_LARGE,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Count Section----->
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "count".tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Transform.scale(
                              scale: _animation.value,
                              child: Obx(
                                () => Text(
                                  translateText(localDhikrController.count.value
                                      .toString()),
                                  style: robotoMedium.copyWith(
                                    fontSize:
                                        Dimensions.FONT_SIZE_EXTRA_LARGE + 30,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),

                      // Add and reset button section ----->
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(child: SizedBox()),

                          Expanded(
                            child: Transform.scale(
                              scale: _animation.value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      Vibration.vibrate(duration: 50);
                                      localDhikrController.localIncrementCount(
                                          localDhikrController.localDhikrId
                                              .toString());
                                      _controller.forward(from: 0);
                                    },
                                    child: SvgPicture.asset(
                                      Images.Icon_Tap_Screen,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.fill,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // // Reset buttion here---->
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // Show the alert dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'are_you_sure_to_reset'.tr,
                                        style: robotoMedium.copyWith(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog
                                            Navigator.of(context).pop();
                                            localDhikrController
                                                .localDeleteCount(
                                                    localDhikrController
                                                        .localDhikrId
                                                        .toString());
                                          },
                                          child: Text(
                                            'yes'.tr,
                                            style: robotoMedium.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Close the dialog
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'no'.tr,
                                            style: robotoMedium.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: SvgPicture.asset(
                                    Images.Icon_Reset,
                                    height: 35,
                                    width: 35,
                                    fit: BoxFit.fill,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: Dimensions.PADDING_SIZE_EXTRA_LARGE)
                    ],
                  ),
          ),
        );
      },
    );
  }
}
