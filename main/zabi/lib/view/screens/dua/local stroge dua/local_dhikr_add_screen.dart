// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/dua_controller.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/view/base/my_text_field.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';
import '../../../base/custom_button.dart';

class LocalDuaAddScreen extends StatelessWidget {
  final bool appBackButton;
  LocalDuaAddScreen({super.key, required this.appBackButton});

  final addDuaformKey = GlobalKey<FormState>();
  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController arabicNameController = TextEditingController();
  final TextEditingController englishDescriptionController =
      TextEditingController();
  final TextEditingController arabicDescriptionController =
      TextEditingController();
  final DuaController localDuaController = Get.put(
    DuaController(duaRepo: Get.find()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: "add_your_dua".tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),

      // body start ==>
      body: Form(
        key: addDuaformKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            const SizedBox(height: 20),

            // english tile text field ===>
            TextFormField(
              controller: englishNameController,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_LARGE,
              ),
              decoration: getTextInputDecoration(context).copyWith(
                filled: true,
                focusColor: Colors.white,
                hintText: "dua_name_english".tr,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'this_field_must_not_be_empty'.tr;
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 20),

            // arabic tile text field ===>
            TextFormField(
              controller: arabicNameController,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
              ),
              decoration: getTextInputDecoration(context).copyWith(
                filled: true,
                focusColor: Colors.white,
                hintText: "dua_name_arabic_optional".tr,
              ),
              validator: (value) {
                return null;
              },
            ),
            const SizedBox(height: 20),

            // english discription text field ===>
            TextFormField(
              maxLines: 3,
              controller: englishDescriptionController,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
              ),
              decoration: getTextInputDecoration(context).copyWith(
                filled: true,
                focusColor: Colors.white,
                hintText: "dua_discription_english".tr,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'this_field_must_not_be_empty'.tr;
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 20),
            // arabic discription text field ===>
            TextFormField(
              maxLines: 3,
              controller: arabicDescriptionController,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.FONT_SIZE_DEFAULT,
              ),
              decoration: getTextInputDecoration(context).copyWith(
                filled: true,
                focusColor: Colors.white,
                hintText: "dua_discription_arabic_optional".tr,
              ),
              validator: (value) {
                return null;
              },
            ),
            const SizedBox(height: 40),

            // submit buttion ==>
            CustomButton(
              buttonWidth: Get.width,
              buttonName: "add_dua".tr,
              onPressed: () async {
                if (addDuaformKey.currentState!.validate()) {
                  localDuaController.addDua(
                    englishNameController.text,
                    arabicNameController.text,
                    englishDescriptionController.text,
                    arabicDescriptionController.text,
                  );
                  addDuaformKey.currentState!.reset();
                  showCustomSnackBar("dua_add_successfully".tr, isError: false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
