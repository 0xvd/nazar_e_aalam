// ignore_for_file: non_constant_identifier_names, deprecated_member_use, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_button.dart';
import 'package:nazar_e_alam/view/screens/zakat/item_field.dart';
import 'package:nazar_e_alam/view/screens/zakat/result_field.dart';
import '../../../controller/zakat_calculator_controller.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';

class ZakatCalculator extends StatefulWidget {
  final bool appBackButton;
  const ZakatCalculator({super.key, required this.appBackButton});

  @override
  State<ZakatCalculator> createState() => _ZakatCalculatorState();
}

class _ZakatCalculatorState extends State<ZakatCalculator> {
  @override
  Widget build(BuildContext context) {
    Get.find<SettingsController>().fetchMosqueSettingsData();
    return Scaffold(
      // Appbar start ===>
      appBar: CustomAppBar(
        title: "zakat_calculator".tr,
        isBackButtonExist: widget.appBackButton == true ? true : false,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(RouteHelper.zakatDetaile);
            },
            icon: SvgPicture.asset(
              Images.Icon_Details,
              color: Get.isDarkMode
                  ? Theme.of(context).textTheme.bodyMedium!.color
                  : Theme.of(context).cardColor,
              height: 28,
            ),
          )
        ],
      ),

      // body start
      body: SingleChildScrollView(
        child: GetBuilder<ZakatCalculatorController>(
          init: ZakatCalculatorController(),
          initState: (_) {},
          builder: (zakatCalculatorController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: zakatCalculatorController.zakatCalculatorformkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
//---------------------------------------------------------//
//----------------- What I OWN section here ---------------//
                    Center(
                      child: Text(
                        "what_i_own".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Divider(),
                    Text(
                      "my_cash".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "enter_the_amount_of_cash_you_have".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "cash_in_bank_accounts".tr,
                      controllerValue: zakatCalculatorController.own_bank_cash,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "cash_in_hand".tr,
                      controllerValue: zakatCalculatorController.own_cash,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "money_owed_to_me".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "if_you_have_lent_money_to_someone_and_are_confident_it_will_be_repaid"
                          .tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "loan".tr,
                      controllerValue: zakatCalculatorController.own_loan,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "money_expected_from_a_sale".tr,
                      controllerValue:
                          zakatCalculatorController.own_money_expected,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "my_gold_and_silver".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "if_you_are_not_sure_how_much_your_gold_and_silver".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "gold".tr,
                      controllerValue: zakatCalculatorController.own_gold,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "silver".tr,
                      controllerValue: zakatCalculatorController.own_silver,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "my_shares".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "if_you_own_stocks_and_shares_zakat_is_due_on_them".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName:
                          "sharesbought_exclusively_to_resell_for_capital_gain"
                              .tr,
                      controllerValue: zakatCalculatorController
                          .own_shares_bought_exclusively,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "shares_bought_for_any_other_reason".tr,
                      controllerValue:
                          zakatCalculatorController.own_shares_bought,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "my_pensions".tr,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "if_you_have_a_defined_contribution_pension_scheme".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "amount_of_pension".tr,
                      controllerValue: zakatCalculatorController.own_pension,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "my_ISAs_junior_ISAs_and_child_trust_funds".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "zakat_is_payable_on_ISAs_and_Child_Trust_Funds".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "stocks_and_shares_ISA_CTF".tr,
                      controllerValue: zakatCalculatorController.own_stocks,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "cash_ISA".tr,
                      controllerValue: zakatCalculatorController.own_cash_isa,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "my_crypto".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "enter_the_value_of_any_cryptocurrencies_you_own_in_pounds"
                          .tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "cryptocurrency_value".tr,
                      controllerValue:
                          zakatCalculatorController.own_cryptocurrency,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "my_business_assets".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      "business_assets_include_cash".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "business_cash".tr,
                      controllerValue:
                          zakatCalculatorController.own_business_cash,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "business_receivables".tr,
                      controllerValue:
                          zakatCalculatorController.own_business_receivables,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "business_stock".tr,
                      controllerValue:
                          zakatCalculatorController.own_business_stock,
                    ),
                    const SizedBox(height: 10),
//---------------------------------------------------------//
//----------------- What I OWE section here ---------------//
                    const Divider(),
                    Center(
                      child: Text(
                        "money_i_owe".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Divider(),
                    Text(
                      "for_long_term_debts".tr,
                      textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_DEFAULT),
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "mortgage".tr,
                      controllerValue: zakatCalculatorController.owe_mortgage,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "utility_bills".tr,
                      controllerValue:
                          zakatCalculatorController.owe_utility_bills,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "personal_loans".tr,
                      controllerValue:
                          zakatCalculatorController.owe_personal_loans,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "overdraft".tr,
                      controllerValue: zakatCalculatorController.owe_overdraft,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "credit_card".tr,
                      controllerValue:
                          zakatCalculatorController.owe_credit_card,
                    ),
                    const SizedBox(height: 10),
                    ItemField(
                      fieldName: "business_liabilities".tr,
                      controllerValue:
                          zakatCalculatorController.owe_business_libilities,
                    ),
                    const SizedBox(height: 10),
                    const Divider(),

                    // Result Section ====>
                    Center(
                      child: Text(
                        "all_done".tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.FONT_SIZE_LARGE,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ResultField(
                              readOnly: true,
                              labelText: "what_i_have".tr,
                              controllerValue:
                                  zakatCalculatorController.totalOwn),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ResultField(
                              readOnly: true,
                              labelText: "what_i_owe".tr,
                              controllerValue:
                                  zakatCalculatorController.totalOwe),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ResultField(
                                readOnly: true,
                                labelText: "is_equal_to".tr,
                                controllerValue:
                                    zakatCalculatorController.equal),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ResultField(
                              readOnly: zakatCalculatorController
                                          .isApiNisabExist.text ==
                                      ""
                                  ? false
                                  : true,
                              labelText: "todays_nisab".tr,
                              controllerValue: Get.find<SettingsController>()
                                          .mosqueSettingsApiData!
                                          .data!
                                          .automaticPayerTime ==
                                      true
                                  ? zakatCalculatorController.totalNisab
                                  : zakatCalculatorController.isApiNisabExist,
                              onSaved: (value) {
                                zakatCalculatorController.nisab = value!;
                              },
                              validator: (value) {
                                return zakatCalculatorController
                                    .validateTotalNisab(value!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            keyboardType: TextInputType.none,
                            controller: zakatCalculatorController.totalZakat,
                            style: const TextStyle(fontSize: 22),
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 70, 10, 20),
                              labelText: "my_zakat_is".tr,
                              labelStyle: TextStyle(
                                fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontWeight: FontWeight.w400,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    CustomButton(
                        buttonWidth: Get.width,
                        buttonName: "click_for_result".tr,
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        onPressed: () {
                          final isValidForm = zakatCalculatorController
                              .zakatCalculatorformkey.currentState!
                              .validate();
                          if (isValidForm) {
                            zakatCalculatorController.getTotalOwn();
                            zakatCalculatorController.getTotalOwe();
                            zakatCalculatorController.getEqual();
                            zakatCalculatorController.getZakat();
                            // zakatCalculatorController.totalNisab.text = "";
                            // zakatCalculatorController
                            //     .zakatCalculatorformkey.currentState!
                            //     .reset();
                          }
                        }),
                    const SizedBox(height: 15),
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
