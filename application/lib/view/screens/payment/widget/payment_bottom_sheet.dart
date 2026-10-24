// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/controller/donation_controller.dart';
// import 'package:nazar_e_alam/util/dimensions.dart';
// import 'package:nazar_e_alam/util/images.dart';
// import 'package:nazar_e_alam/util/styles.dart';
// import 'package:nazar_e_alam/view/base/custom_button.dart';
// import 'package:nazar_e_alam/view/base/my_text_field.dart';

// class PaymentBottomSheetScreen extends StatefulWidget {
//   final String name;
//   final String type;
//   const PaymentBottomSheetScreen({
//     super.key,
//     required this.name,
//     required this.type,
//   });

//   @override
//   State<PaymentBottomSheetScreen> createState() =>
//       _PaymentBottomSheetScreenState();
// }

// class _PaymentBottomSheetScreenState extends State<PaymentBottomSheetScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   @override
//   void initState() {
//     amountController.text;
//     emailController.text;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     amountController.dispose();
//     emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Get.find<DonationController>().paymentMethodListData();
//     return GetBuilder<DonationController>(
//       builder: (donationController) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: Dimensions.PADDING_SIZE_DEFAULT,
//             vertical: Dimensions.PADDING_SIZE_DEFAULT,
//           ),
//           child: Form(
//             key: _formKey,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // quran settings header
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Image.asset(
//                         widget.type == "paypal"
//                             ? Images.Icon_Paypal
//                             : widget.type == "stripe"
//                             ? Images.Icon_Stripe
//                             : widget.type == "paystack"
//                             ? Images.Icon_Paystack
//                             : widget.type == "razorpay"
//                             ? Images.Icon_Razorpay
//                             : widget.type == "sslcommerz"
//                             ? Images.Icon_SSLCommerz
//                             : Images.Icon_Haram,
//                         height: 25,
//                         fit: BoxFit.fill,
//                       ),
//                       Text(
//                         widget.name.tr,
//                         textAlign: TextAlign.center,
//                         style: robotoMedium.copyWith(
//                           fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Get.back();
//                         },
//                         child: Text(
//                           "close".tr,
//                           style: robotoMedium.copyWith(
//                             color: Theme.of(context).colorScheme.error,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(),

//                   TextFormField(
//                     keyboardType: const TextInputType.numberWithOptions(
//                       decimal: true,
//                     ),
//                     inputFormatters: <TextInputFormatter>[
//                       FilteringTextInputFormatter.allow(
//                         RegExp(r'^\d+\.?\d{0,2}'),
//                       ),
//                     ],
//                     controller: amountController,
//                     style: robotoMedium.copyWith(
//                       fontSize: Dimensions.FONT_SIZE_LARGE,
//                     ),
//                     decoration: getTextInputDecoration(context).copyWith(
//                       filled: true,
//                       focusColor: Colors.white,
//                       hintText: "enter_amount".tr,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'this_field_must_not_be_empty'.tr;
//                       } else {
//                         return null;
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: emailController,
//                     style: robotoMedium.copyWith(
//                       fontSize: Dimensions.FONT_SIZE_LARGE,
//                     ),
//                     decoration: getTextInputDecoration(context).copyWith(
//                       filled: true,
//                       focusColor: Colors.white,
//                       hintText: "enter_your_email".tr,
//                     ),
//                     validator: (value) {
//                       if (!GetUtils.isEmail(value!)) {
//                         return 'enter_valid_email'.tr;
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "10".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '10';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "20".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '20';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "30".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '30';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "40".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '40';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "50".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '50';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "100".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '100';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "500".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '500';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "1000".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '1000';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 4.0),
//                           child: CustomButton(
//                             buttonWidth: Get.width,
//                             buttonName: "10000".tr,
//                             onPressed: () async {
//                               setState(() {
//                                 String data = '10000';
//                                 amountController.text = data;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),

//                   // submit buttion ==>
//                   CustomButton(
//                     buttonLoderWidget: donationController.isAddedLoading.value
//                         ? const Center(
//                             child: SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           )
//                         : null,
//                     buttonWidth: Get.width,
//                     buttonName: "go_for_payment".tr,
//                     disableColor:
//                         (amountController.text.isNotEmpty &&
//                             emailController.text.isNotEmpty)
//                         ? Theme.of(context).primaryColor
//                         : Theme.of(context).disabledColor,
//                     onPressed:
//                         amountController.text.isEmpty &&
//                             emailController.text.isEmpty
//                         ? () {}
//                         : () async {
//                             if (_formKey.currentState!.validate()) {
//                               Get.back();
//                               donationController.razorpayValue(
//                                 emailController.text,
//                                 amountController.text,
//                               );
//                               donationController.paymentGateWayFun(
//                                 context,
//                                 amountController.text,
//                                 emailController.text,
//                               );
//                             }
//                           },
//                   ),

//                   const Divider(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
