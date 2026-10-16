import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/util/styles.dart';

import '../../../controller/alphabet_controller.dart';
import '../../../util/dimensions.dart';
import '../../base/loading_indicator.dart';

void openAlphabetSettings(BuildContext context) {
  showModalBottomSheet(
    enableDrag: false,
    isDismissible: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
        topRight: Radius.circular(Dimensions.RADIUS_EXTRA_LARGE),
      ),
    ),
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return GetBuilder<AlphabetController>(
        builder: (alphabetController) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_DEFAULT,
              vertical: Dimensions.PADDING_SIZE_DEFAULT,
            ),
            child: SizedBox(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: null,
                        child: Text(
                          "",
                          style: robotoMedium.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      Text(
                        'alphabet_settings'.tr,
                        textAlign: TextAlign.center,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "close".tr,
                          style: robotoMedium.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Obx(() {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('voice_key'.tr, style: robotoMedium),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                          top: Dimensions.PADDING_SIZE_DEFAULT,
                        ),
                        child: Container(
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
                          child: alphabetController.availableVoices.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                    ),
                                    child: LoadingIndicator(),
                                  ),
                                )
                              : DropdownButtonFormField<Map>(
                                  isExpanded: true,
                                  initialValue:
                                      alphabetController.selectedVoice.value,
                                  items: alphabetController.availableVoices.map(
                                    (voice) {
                                      return DropdownMenuItem<Map>(
                                        value: voice,
                                        child: Text(
                                          alphabetController
                                                  .voiceDisplayNames[voice] ??
                                              voice['name'] ??
                                              '',
                                          style: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_DEFAULT,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (voice) async {
                                    if (voice != null) {
                                      await alphabetController.setVoice(voice);
                                      alphabetController.speak(
                                        'السلام عليكم ورحمة الله وبركاته',
                                      );
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),

                  const Divider(),

                  // Pitch slider
                  Obx(
                    () => ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(
                        'pitch_key'.tr,
                        style: robotoMedium.copyWith(),
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: alphabetController.pitch.value,
                              min: 0.0,
                              max: 10.0,
                              onChanged: (value) {
                                alphabetController.setPitch(value);
                              },
                            ),
                          ),
                          Text(
                            alphabetController.pitch.value.toStringAsFixed(1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),

                  // Rate slider
                  Obx(
                    () => ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      title: Text(
                        'speech_rate_key'.tr,
                        style: robotoMedium.copyWith(),
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              min: 0.1,
                              max: 1.0,
                              value: alphabetController.rate.value,
                              onChanged: (value) {
                                alphabetController.setRate(value);
                              },
                            ),
                          ),
                          Text(
                            alphabetController.rate.value.toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
