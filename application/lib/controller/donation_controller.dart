// ignore_for_file: deprecated_member_use, strict_top_level_inference

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/repository/donation_repo.dart';

import '../data/model/response/donation_category_model.dart';
import '../data/model/response/donation_list_model.dart';
import '../data/model/response/payment_method_model.dart';
import '../helper/route_helper.dart';
import '../view/base/custom_snackbar.dart';

class DonationController extends GetxController implements GetxService {
  final DonationRepo donationRepo;
  DonationController({required this.donationRepo});
  final TextEditingController emailController = TextEditingController();

  String? selectData;

  String? _paymentGatewayType;
  String? get paymentGatewayType => _paymentGatewayType;

  String? _paymentGatewayApiKey;
  String? get paymentGatewayApiKey => _paymentGatewayApiKey;

  String? _paymentGatewayApiSecret;
  String? get paymentGatewayApiSecret => _paymentGatewayApiSecret;

  int? _categoryId;
  int? get categoryId => _categoryId;

  int? _paymentMethodId;
  int? get paymentMethodId => _paymentMethodId;

  String? _paymentMode;
  String? get paymentMode => _paymentMode;

  @override
  void onInit() {
    //razorpay...............
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    //razorpay...............

    _loadEmail();
    super.onInit();
  }

  // local variable
  RxBool isCategoryListLoading = false.obs;
  RxBool isPaymentListLoading = false.obs;
  RxBool isDonatedListLoading = false.obs;
  RxBool isAddedLoading = false.obs;
  DonationCategoryModel? donationCategoryData;
  DonationListModel? donationListData;
  PaymentMethodModel? paymentListData;

  void _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('selectedEmail');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
    }
  }

  // get donation donation form here
  Future<void> donationCategoryListData() async {
    try {
      isCategoryListLoading(true);
      update();

      final response = await donationRepo.getDonationCategoryLisRepo();

      if (response.statusCode == 200) {
        donationCategoryData = DonationCategoryModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isCategoryListLoading(false);
      update();
    }
  }

  Future<void> addDonation(categoryId, email, amount, paymentMethodId) async {
    try {
      isAddedLoading(true);
      update();
      isPaymentListLoading(true);
      isCategoryListLoading(true);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('selectedEmail', '$email');

      final response = await donationRepo.addDonationRepo(
        map: {
          "category_id": categoryId,
          "email": email,
          "amount": amount,
          "payment_method_id": paymentMethodId,
        },
      );
      if (kDebugMode) {
        print("body: ${response.body}");
      }
      var decoded = json.decode(response.body);

      if (response.statusCode == 200 && response.body['status'] == true) {
        donatedListData();
        showCustomSnackBar("Payment Successfully", isError: false);
      } else {
        showCustomSnackBar(decoded["message"], isError: true);

        isAddedLoading(false);
        donatedListData();
        update();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      // isAddedLoading(false);
      isPaymentListLoading(false);
      isCategoryListLoading(false);
      isAddedLoading(false);
      update();
    }
  }

  // get donated list form here

  Future<void> donatedListData({String? selectedEmail}) async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

    try {
      // Reset loading state to force fresh fetch
      isDonatedListLoading(true);
      update();

      final prefs = await SharedPreferences.getInstance();
      var selectedEmailName =
          selectedEmail ?? prefs.getString('selectedEmail') ?? "";

      final response = await donationRepo.getDonatedListLisRepo(
        selectedEmailName,
        currentTimeZone,
      );

      if (response.statusCode == 200) {
        donationListData = DonationListModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching data: $e");
    } finally {
      isDonatedListLoading(false);
      update();
    }
  }

  //   Future<void> donatedListData({String? selectedEmail}) async {
  //     final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  //
  //     try {
  //       isDonatedListLoading(true);
  //       update();
  //       final prefs = await SharedPreferences.getInstance();
  //       var selectedEmailName =
  //           selectedEmail ?? prefs.getString('selectedEmail') ?? "";
  //
  //       // final response = await donationRepo.getDonatedListLisRepo(
  //       //     "${AppConstants.DONATED_LIST}?email=$selectedEmailName&timezone=$currentTimeZone");
  //
  //       final response = await donationRepo.getDonatedListLisRepo(
  //           selectedEmailName, currentTimeZone);
  //
  //       if (response.statusCode == 200) {
  //         donationListData = DonationListModel.fromJson(response.body);
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print("Error fetching data: $e");
  //       }
  //     } finally {
  //       isDonatedListLoading(false);
  //       update();
  //     }
  //   }

  // get donated list form here
  Future<void> paymentMethodListData() async {
    try {
      isPaymentListLoading(true);

      final response = await donationRepo.getPaymentMethodListRepo();

      if (response.statusCode == 200) {
        paymentListData = PaymentMethodModel.fromJson(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isPaymentListLoading(false);
      update();
    }
  }

  setPaymentGatewayValue(
    type,
    apiKey,
    apiSecret,
    categoryId,
    paymentMethodId,
    paymentMode,
  ) {
    _paymentGatewayType = type;
    _paymentGatewayApiKey = apiKey;
    _paymentGatewayApiSecret = apiSecret;
    _categoryId = categoryId;
    _paymentMethodId = paymentMethodId;
    _paymentMode = paymentMode;
    update();
  }

  paymentGateWayFun(BuildContext context, amount, email) {
    if (_paymentGatewayType == "paypal") {
      Get.to(
        () => UsePaypal(
          sandboxMode: _paymentMode == "sandbox"
              ? true
              : false, //set sandbox true,
          // sandboxMode: true,
          // clientId: "AW1TdvpSGbIM5iP4HJNI5TyTmwpY9Gv9dYw8_8yW5lYIbCqf326vrkrp0ce9TAqjEGMHiV3OqJM_aRT0",
          clientId: "$_paymentGatewayApiKey",
          secretKey: "$_paymentGatewayApiSecret",
          // secretKey: "EHHtTDjnmTZATYBPiGzZC_AZUfMpMAzj2VZUeqlFUrRJA_C0pQNCxDccB5qoRQSEdcOnnKQhycuOWdP9",
          returnURL: "https://samplesite.com/return",
          cancelURL: "https://samplesite.com/cancel",
          transactions: [
            {
              "amount": {
                "total": '$amount',
                "currency": "USD",
                "details": {
                  "subtotal": '$amount',
                  "shipping": '0',
                  "shipping_discount": 0,
                },
              },
              "description": "$email",
              "item_list": {
                "items": [
                  {
                    "name": "Donation Amount",
                    "quantity": 1,
                    "price": '$amount',
                    "currency": "USD",
                  },
                ],
              },
            },
          ],
          note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            addDonation(_categoryId, email, amount, _paymentMethodId).then((
              value,
            ) {
              Get.toNamed(RouteHelper.getDonationListPageRoute("2"));
              update();
            });
            showCustomSnackBar("Payment Successfully", isError: false);
          },
          onError: (error) {
            showCustomSnackBar("Payment Error\n$error", isError: true);
          },
          onCancel: (params) {
            showCustomSnackBar("Payment Cancelled\n$params", isError: true);
          },
        ),
      );
      update();
    } else if (_paymentGatewayType == "stripe") {
      double data = double.parse(amount);
      final castPayment = double.parse((data * 100).toString()).round();
      makeStripePaymentFun(
        calculationAmount: '$castPayment',
        currency: 'USD',
        email: email,
        withoutCalculateAmount: data.toString(),
      );
      update();
    } else if (_paymentGatewayType == "paystack") {
      makePayStack(context, amount, email);
      update();
    } else if (_paymentGatewayType == "razorpay") {
      razorpayCheckout(amount, _categoryId, email);
      update();
    } else if (_paymentGatewayType == "sslcommerz") {
      sslPayCheckout(amount, _categoryId, email);
      update();
    } else {
      showCustomSnackBar("Payment Method Not Found", isError: true);
      update();
    }
  }

  @override
  void dispose() {
    donationCategoryData?.data?.clear();
    paymentListData?.data?.clear();
    _razorpay.clear();
    paymentIntentData?.clear();
    super.dispose();
  }

  //razorpay...............
  String? _selectEmail;
  String? get selectEmail => _selectEmail;

  String? _selectAmount;
  String? get selectAmount => _selectAmount;

  razorpayValue(email, amount) {
    _selectEmail = email;
    _selectAmount = amount;
  }

  late Razorpay _razorpay;

  void razorpayCheckout(dynamic amount, dynamic category, dynamic email) {
    final price = double.tryParse(amount)! * 100;

    var options = {
      // 'key': 'rzp_test_lGm5FLE0Ty9evM', //<YOUR_KEY_ID>
      'key': '$_paymentGatewayApiKey', //<YOUR_KEY_ID>
      "id": "$category",
      "entity": "Due invoice",
      "amount": price,
      "currency": "INR",
      "receipt": "Category Id : $category",
      'prefill': {'email': '$email'},
      "attempts": 0,
      "notes": [],
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    addDonation(
      _categoryId,
      _selectEmail,
      _selectAmount,
      _paymentMethodId,
    ).then((value) {
      Get.toNamed(RouteHelper.getDonationListPageRoute("2"));
    });
    showCustomSnackBar("Payment Successfully", isError: false);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    showCustomSnackBar("Payment Failure\n\n${response.message}", isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    showCustomSnackBar(
      "External wallet \n\n${response.walletName}",
      isError: false,
    );
  }

  //razorpay...............

  //stripe

  Map<dynamic, dynamic>? paymentIntentData;

  displayPaymentSheet(email, amount) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      addDonation(_categoryId, email, amount, _paymentMethodId).then((value) {
        Get.toNamed(RouteHelper.getDonationListPageRoute("2"));
      });
      showCustomSnackBar("Payment Successfully", isError: false);
    } on Exception catch (e) {
      if (e is StripeException) {
        showCustomSnackBar('${e.error.localizedMessage}', isError: true);
      } else {
        showCustomSnackBar("Payment Cancelled \n$e", isError: true);
      }
    } catch (e) {
      if (kDebugMode) {
        print("exception $e");
        showCustomSnackBar("exception $e", isError: true);
      }
    }
  }

  createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      Map<String, dynamic> body = {
        "amount": amount,
        "currency": currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization": "Bearer $_paymentGatewayApiSecret",
          // "Authorization": "Bearer sk_test_51NkfZPQcTOlW4Idi1SYhuJ4hFHbEMQYtPZBTPeW0YRJ2uW4RxBsWHH8DLxbXJGYN781sF2EFT4aMuE9aWno7XtuR0084CvLCRs",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print("CONNECT YOUR INTERNET CONNECTION..error charging user$e");
        showCustomSnackBar("$e", isError: true);
      }
      showCustomSnackBar("$e", isError: true);
      // EasyLoading.showError("CONNECT YOUR INTERNET CONNECTION.. exception error charging user $e");
    }
  }

  Future<void> makeStripePaymentFun({
    required String calculationAmount,
    required String currency,
    required String email,
    required String withoutCalculateAmount,
  }) async {
    Stripe.publishableKey = "$_paymentGatewayApiKey";
    // Stripe.publishableKey = "pk_test_51NkfZPQcTOlW4IdimsgJedt6Yh48183nWQsWen9OoOQojmPGO1b9coUJXDky8HBPXyEhNcvoZ4QripbP5Ye8PL6R00bCZWDVQK";

    try {
      paymentIntentData = await createPaymentIntent(
        amount: calculationAmount,
        currency: currency,
      );

      var gPay = PaymentSheetGooglePay(
        merchantCountryCode: currency,
        currencyCode: currency,
        testEnv: false,
      );

      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            billingDetails: BillingDetails(name: "", email: email, phone: ""),
            billingDetailsCollectionConfiguration:
                const BillingDetailsCollectionConfiguration(
                  phone: CollectionMode.always,
                  email: CollectionMode.always,
                  name: CollectionMode.always,
                  attachDefaultsToPaymentMethod: false,
                ),
            style: ThemeMode.dark,
            merchantDisplayName: "Prospects",
            customerId: paymentIntentData!["customer"],
            paymentIntentClientSecret: paymentIntentData!["client_secret"],
            customerEphemeralKeySecret: paymentIntentData!["ephemeralKey"],
            googlePay: gPay,
          ),
        );
        displayPaymentSheet(email, withoutCalculateAmount);
      }
    } catch (e, s) {
      if (kDebugMode) {
        print("exception:$e$s");
        showCustomSnackBar("exception $e $s", isError: true);
      }
    }
  }

  //stripe
  bool initializingPayment = false;
  //PayStack
  String generateRef() {
    final randomCode = Random().nextInt(3234234);
    return 'ref-$randomCode';
  }

  Future<void> makePayStack(BuildContext context, amount, email) async {
    final ref = generateRef();
    double data = double.parse(amount);
    final castPayment = double.parse((data * 100).toString()).round();

    try {
      return await FlutterPaystackPlus.openPaystackPopup(
        // publicKey: 'pk_test_d1f76f0f1becd6dfa958baa16fe1d48a2ddd94ab',
        publicKey: '$_paymentGatewayApiKey',
        context: context,
        secretKey: '$_paymentGatewayApiSecret',
        // secretKey: 'sk_test_002ca03800074bd40cf2a199395715fa7cc84f21',
        currency: 'ZAR',
        customerEmail: '$email',
        // amount: (1.12 * 100).toString(),
        amount: castPayment.toString(),
        reference: ref,
        callBackUrl: "https://paystack.com",
        onClosed: () {
          debugPrint('Could\'nt finish payment');
          showCustomSnackBar("Couldn't finish payment", isError: true);
        },
        onSuccess: () {
          addDonation(_categoryId, email, amount, _paymentMethodId).then((
            value,
          ) {
            Get.toNamed(RouteHelper.getDonationListPageRoute("2"));
          });
          debugPrint('Payment successful');
          showCustomSnackBar("Payment Successfully", isError: false);
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      showCustomSnackBar(
        "Something Went Wrong \n${e.toString()}",
        isError: true,
      );
    }
  }

  // PayStack

  Future<void> sslPayCheckout(
    dynamic amount,
    dynamic categoryId,
    dynamic email,
  ) async {
    try {
      final Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          multi_card_name: "visa,master,bkash",
          currency: SSLCurrencyType.BDT,
          product_category: "Donation",
          sdkType: _paymentMode == "sandbox"
              ? SSLCSdkType.TESTBOX
              : SSLCSdkType.LIVE,
          store_id: "$_paymentGatewayApiKey",
          store_passwd: "$_paymentGatewayApiSecret",
          total_amount: double.parse(amount.toString()),
          tran_id: "DONATION_${DateTime.now().millisecondsSinceEpoch}",
        ),
      );

      final SSLCTransactionInfoModel result = await sslcommerz.payNow();

      debugPrint("SSL Status => ${result.status}");

      if (result.status?.toLowerCase() == "failed") {
        showCustomSnackBar(
          "Transaction Failed\n\n${result.status}",
          isError: true,
        );
      } else if (result.status?.toLowerCase() == "closed") {
        showCustomSnackBar(
          "Payment Cancelled\n\n${result.status}",
          isError: true,
        );
      } else {
        addDonation(categoryId, email, amount, _paymentMethodId).then((value) {
          Get.toNamed(RouteHelper.getDonationListPageRoute("2"));
        });

        showCustomSnackBar("Payment Successfully", isError: false);
      }
    } catch (e) {
      showCustomSnackBar("Payment Error\n$e", isError: true);
    }
  }
}
