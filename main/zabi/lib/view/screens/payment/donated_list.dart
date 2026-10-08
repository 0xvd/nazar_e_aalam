// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';

import '../../../controller/donation_controller.dart';
import '../../../controller/quran_settings_controller.dart';
import '../../../helper/route_helper.dart';
import '../../../util/dimensions.dart';
import '../../../util/images.dart';
import '../../../util/styles.dart';
import '../../base/custom_app_bar.dart';
import '../../base/my_text_field.dart';

class UserDonateScreen extends StatelessWidget {
  final bool appBackButton;
  final String value;
  UserDonateScreen({super.key, required this.appBackButton, this.value = '1'});

  final RxBool showTextField = false.obs;
  final _formKey = GlobalKey<FormState>();
  final DonationController donationController = Get.find<DonationController>();

  @override
  Widget build(BuildContext context) {
    donationController.donatedListData();

    return WillPopScope(
      onWillPop: () async {
        if (int.parse(value) == 2) {
          Get.offAllNamed(RouteHelper.bottomNavbar);
        } else {
          Get.back();
        }
        return false;
      },
      child: Scaffold(
        // Appbar start ===>
        appBar: CustomAppBar(
          title: "donated_list".tr,
          isBackButtonExist: appBackButton == true ? true : false,
          onBackPressed: () {
            int.parse(value) == 2
                ? Get.offAllNamed(RouteHelper.bottomNavbar)
                : Get.back();
          },
          actions: [
            IconButton(
              onPressed: () {
                showTextField.value = !showTextField.value;
              },
              icon: SvgPicture.asset(
                Images.Icon_Filter,
                height: 20,
                fit: BoxFit.fill,
                color: Get.isDarkMode
                    ? Theme.of(context).textTheme.bodyMedium!.color
                    : Theme.of(context).cardColor,
              ),
            ),
          ],
        ),

        // body start ===>
        body: GetBuilder<DonationController>(
          builder: (donationController) {
            return SingleChildScrollView(
              child: Obx(
                () => Column(
                  children: [
                    showTextField.value == true
                        ? Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_DEFAULT,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_DEFAULT - 2,
                                  ),
                                  color: Theme.of(context).cardColor,
                                ),
                                child: TextFormField(
                                  controller:
                                      donationController.emailController,
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_LARGE,
                                  ),
                                  validator: (value) {
                                    if (!GetUtils.isEmail(value!)) {
                                      return 'enter_valid_email'.tr;
                                    }
                                    return null;
                                  },
                                  decoration: getTextInputDecoration(context).copyWith(
                                    filled: true,
                                    hintText: "enter_your_email".tr,
                                    suffixIcon: GestureDetector(
                                      onTap: () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Save the entered email in SharedPreferences
                                          final prefs =
                                              await SharedPreferences.getInstance();
                                          prefs.setString(
                                            'selectedEmail',
                                            donationController
                                                .emailController
                                                .text,
                                          );
                                          // Update the donatedListData with the entered email
                                          Get.find<DonationController>()
                                              .donatedListData(
                                                selectedEmail:
                                                    donationController
                                                        .emailController
                                                        .text,
                                              );
                                        }
                                      },
                                      child: const Icon(Icons.search),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(
                      height: showTextField.value == true
                          ? MediaQuery.of(context).size.height / 1.3
                          : MediaQuery.of(context).size.height / 1.1,
                      child: donationController.isDonatedListLoading.value
                          ? const Center(child: DonatedShimmer())
                          : (donationController
                                    .donationListData
                                    ?.data
                                    ?.isEmpty ??
                                true)
                          ? Center(
                              child: Text(
                                "no_data_found".tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_LARGE,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_SMALL,
                              ),
                              itemCount: donationController
                                  .donationListData
                                  ?.data
                                  ?.length,
                              itemBuilder: (context, index) {
                                var apiData = donationController
                                    .donationListData
                                    ?.data![index];
                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: Theme.of(context).cardColor,
                                  shadowColor: Get.isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsetsDirectional.only(
                                          start: Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL,
                                          end: Dimensions.PADDING_SIZE_SMALL,
                                        ),
                                    leading: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        top: 5.0,
                                      ),
                                      child: Image.asset(
                                        apiData!.paymentMethod == "Paypal"
                                            ? Images.Icon_Paypal
                                            : apiData.paymentMethod == "Stripe"
                                            ? Images.Icon_Stripe
                                            : apiData.paymentMethod ==
                                                  "Paystack"
                                            ? Images.Icon_Paystack
                                            : apiData.paymentMethod ==
                                                  "Razorpay"
                                            ? Images.Icon_Razorpay
                                            : apiData.paymentMethod ==
                                                  "Sslcommerz"
                                            ? Images.Icon_SSLCommerz
                                            : Images.Icon_Haram,
                                        height: 30,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    title: Text(
                                      '${apiData.category}',
                                      style: robotoMedium.copyWith(
                                        fontSize: Get.find<SettingsController>()
                                            .translateFontSize
                                            .value,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${apiData.date}',
                                      style: robotoMedium.copyWith(
                                        fontSize: Get.find<SettingsController>()
                                            .translateFontSize
                                            .value,
                                      ),
                                    ),
                                    trailing: Text(
                                      "${Get.find<SettingsController>().mosqueSettingsApiData?.data?.currencySymbol}${apiData.amount} ",
                                      style: robotoMedium.copyWith(
                                        fontSize: Get.find<SettingsController>()
                                            .translateFontSize
                                            .value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
