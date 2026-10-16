import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/dhikr_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';

class ApiDikirWidget extends StatelessWidget {
  const ApiDikirWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DhikrController>(
      builder: (dikirListController) {
        return dikirListController.isDikirListLoading.value ||
                dikirListController.dikirListApiData == null
            ? const Center(
                child: DhikirShimmer(),
              )
            : dikirListController.dikirListApiData!.data!.isEmpty
                ? Center(
                    child: Text(
                      "no_data_found".tr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // default dikir show ==>
                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          itemCount: dikirListController
                              .dikirListApiData!.data!.length,
                          itemBuilder: (context, index) {
                            var apiData = dikirListController
                                .dikirListApiData!.data![index];
                            return GestureDetector(
                              onTap: () {
                                var dikirDetailsController =
                                    Get.find<DhikrController>();
                                dikirDetailsController.fetchDikirDetailsData(
                                    dikirId: apiData.id.toString());
                                dikirDetailsController.dikirId =
                                    apiData.id.toString();
                                Get.toNamed(RouteHelper.dhikrCount);
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
                                              Dimensions.PADDING_SIZE_DEFAULT),

                                  // Dhikr Title English---->
                                  title: Text(
                                    apiData.enShortName.toString(),
                                    style: robotoMedium.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_LARGE),
                                  ),
                                  trailing: Text(
                                    apiData.arShortName.toString(),
                                    style:  Get.find<SettingsController>()
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
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
      },
    );
  }
}
