// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../controller/donation_controller.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/images.dart';
import '../../../../util/styles.dart';
import '../../../base/custom_button.dart';
import '../../../base/my_text_field.dart';

class DonatedFilterScreen extends StatefulWidget {
  const DonatedFilterScreen({super.key});

  @override
  State<DonatedFilterScreen> createState() => _DonatedFilterScreenState();
}

class _DonatedFilterScreenState extends State<DonatedFilterScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<DonationController>().donatedListData();
    });

    return GetBuilder<DonationController>(
      builder: (donationController) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // free space
                const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                // Filter section
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimensions.RADIUS_DEFAULT - 2),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Date Range section
                      Positioned(
                        top: -40,
                        right: -20,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            donationController.emailController.clear();
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Colors.black)),
                            child: const Icon(
                              Icons.clear,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: donationController.emailController,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE),
                        decoration: getTextInputDecoration(context).copyWith(
                          filled: true,
                          hintText: "enter_your_email".tr,
                        ),
                        validator: (value) {
                          if (!GetUtils.isEmail(value!)) {
                            return 'enter_valid_email'.tr;
                          }
                          return null;
                        },
                        onChanged: (value) async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('selectedEmail',
                              donationController.emailController.text);
                          Get.find<DonationController>().donatedListData(
                              selectedEmail:
                                  donationController.emailController.text);
                        },
                      ),
                    ],
                  ),
                ),

                // free space
                // const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                // const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                //

                // Button section
                Row(
                  children: [
                    // Refresh button
                    InkWell(
                      onTap: () {
                        Get.back();
                        // emailController.clear();
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: SvgPicture.asset(
                          Images.Icon_Refresh,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    // Free space
                    const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                    // Apply filter button
                    Expanded(
                      child: CustomButton(
                          buttonWidth: Get.width,
                          buttonName: "apply_filter".tr,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // final prefs = await SharedPreferences.getInstance();
                              // prefs.setString('selectedEmail', emailController.text);
                              // Get.find<DonationController>().donatedListData(selectedEmail: emailController.text);
                              // Get.back();
                              // emailController.clear();
                            }
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              ],
            ),
          ),
        );
      },
    );
  }
}
