// ignore_for_file: non_constant_identifier_names, prefer_null_aware_operators, strict_top_level_inference

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

class ZakatCalculatorController extends GetxController {
  final zakatCalculatorformkey = GlobalKey<FormState>();

//------------- Global Variable forSection   ------------//
  double oweResult = 0;
  double ownResult = 0;
  double equalResult = 0;
  double total_zakat = 0;

//------------- All result TextEditingController Section   ------------//
  final totalOwn = TextEditingController();
  final totalOwe = TextEditingController();
  final equal = TextEditingController();
  final isApiNisabExist = TextEditingController(
      text: Get.find<SettingsController>()
                  .mosqueSettingsApiData!
                  .data!
                  .automaticPayerTime ==
              true
          ? null
          : Get.find<SettingsController>()
                      .mosqueSettingsApiData!
                      .data!
                      .zakatNisab ==
                  null
              ? null
              : "${Get.find<SettingsController>().mosqueSettingsApiData!.data!.currencySymbol} ${Get.find<SettingsController>().mosqueSettingsApiData!.data!.zakatNisab}");
  final totalNisab = TextEditingController(
      text: Get.find<SettingsController>()
                  .mosqueSettingsApiData!
                  .data!
                  .automaticPayerTime ==
              true
          ? null
          : Get.find<SettingsController>()
                      .mosqueSettingsApiData!
                      .data!
                      .zakatNisab ==
                  null
              ? null
              : Get.find<SettingsController>()
                  .mosqueSettingsApiData!
                  .data!
                  .zakatNisab
                  .toString());
  final totalZakat = TextEditingController();
  String nisab = "";
  String? validateTotalNisab(String value) {
    if (value.isEmpty) {
      return 'enter_your_Current_Nisab'.tr;
    }
    return null;
  }

//------------- Variable for Own section ------------//

  final own_bank_cash = TextEditingController();
  final own_cash = TextEditingController();
  final own_loan = TextEditingController();
  final own_money_expected = TextEditingController();
  final own_gold = TextEditingController();
  final own_silver = TextEditingController();
  final own_shares_bought_exclusively = TextEditingController();
  final own_shares_bought = TextEditingController();
  final own_pension = TextEditingController();
  final own_stocks = TextEditingController();
  final own_cash_isa = TextEditingController();
  final own_cryptocurrency = TextEditingController();
  final own_business_cash = TextEditingController();
  final own_business_receivables = TextEditingController();
  final own_business_stock = TextEditingController();

  //------------- Variable for Owe section ------------//
  final owe_mortgage = TextEditingController();
  final owe_utility_bills = TextEditingController();
  final owe_personal_loans = TextEditingController();
  final owe_overdraft = TextEditingController();
  final owe_credit_card = TextEditingController();
  final owe_business_libilities = TextEditingController();

  getTotalOwn() {
    double ownSum =
        double.parse(own_bank_cash.text == "" ? "0" : own_bank_cash.text) +
            double.parse(own_cash.text == "" ? "0" : own_cash.text) +
            double.parse(own_loan.text == "" ? "0" : own_loan.text) +
            double.parse(
                own_money_expected.text == "" ? "0" : own_money_expected.text) +
            double.parse(own_gold.text == "" ? "0" : own_gold.text) +
            double.parse(own_silver.text == "" ? "0" : own_silver.text) +
            double.parse(own_shares_bought_exclusively.text == ""
                ? "0"
                : own_shares_bought_exclusively.text) +
            double.parse(
                own_shares_bought.text == "" ? "0" : own_shares_bought.text) +
            double.parse(own_pension.text == "" ? "0" : own_pension.text) +
            double.parse(own_stocks.text == "" ? "0" : own_stocks.text) +
            double.parse(own_cash_isa.text == "" ? "0" : own_cash_isa.text) +
            double.parse(
                own_cryptocurrency.text == "" ? "0" : own_cryptocurrency.text) +
            double.parse(
                own_business_cash.text == "" ? "0" : own_business_cash.text) +
            double.parse(own_business_receivables.text == ""
                ? "0"
                : own_business_receivables.text) +
            double.parse(
                own_business_stock.text == "" ? "0" : own_business_stock.text);
    ownResult = ownSum;
    totalOwn.text = ownResult.toString();
  }

  getTotalOwe() {
    double ownSum = double.parse(
            owe_mortgage.text == "" ? "0" : owe_mortgage.text) +
        double.parse(
            owe_utility_bills.text == "" ? "0" : owe_utility_bills.text) +
        double.parse(
            owe_personal_loans.text == "" ? "0" : owe_personal_loans.text) +
        double.parse(owe_overdraft.text == "" ? "0" : owe_overdraft.text) +
        double.parse(owe_credit_card.text == "" ? "0" : owe_credit_card.text) +
        double.parse(owe_business_libilities.text == ""
            ? "0"
            : owe_business_libilities.text);
    oweResult = ownSum;
    totalOwe.text = oweResult.toString();
  }

  getEqual() {
    equalResult = ownResult - oweResult;

    equal.text = equalResult.toString();
  }

  getZakat() {
    if (equalResult > double.parse(totalNisab.text)) {
      total_zakat = (equalResult * 2.5) / 100;
      totalZakat.text =
          "${Get.find<SettingsController>().mosqueSettingsApiData!.data!.automaticPayerTime == true ? "" : Get.find<SettingsController>().mosqueSettingsApiData!.data!.currencySymbol} $total_zakat";

      if (kDebugMode) {
        print("total Zakat =====> ${totalZakat.text}");
      }
    } else {
      totalZakat.text = "zakat_is_not_obligatory_on_you".tr;
    }
  }
}
