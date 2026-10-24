// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
// import 'package:nazar_e_alam/view/screens/payment/widget/payment_bottom_sheet.dart';

// import '../../../controller/donation_controller.dart';
// import '../../../controller/quran_settings_controller.dart';
// import '../../../util/dimensions.dart';
// import '../../../util/images.dart';
// import '../../../util/styles.dart';
// import '../../base/custom_app_bar.dart';

// class PaymentTypeScreen extends StatelessWidget {
//   final bool appBackButton;
//   final donationCatagoryId = Get.arguments;
//   PaymentTypeScreen({super.key, required this.appBackButton});

//   @override
//   Widget build(BuildContext context) {
//     Get.find<DonationController>().paymentMethodListData();
//     return Scaffold(
//       // Appbar start ===>
//       appBar: CustomAppBar(
//         title: "payment_type".tr,
//         isBackButtonExist: appBackButton == true ? true : false,
//       ),

//       // body start ===>
//       body: GetBuilder<DonationController>(
//         builder: (donationController) {
//           return donationController.paymentListData == null
//               ? const Center(child: DonationTypeShimmer())
//               : donationController.paymentListData!.data!.isEmpty
//               ? Center(
//                   child: Text(
//                     "no_data_found".tr,
//                     style: robotoMedium.copyWith(
//                       fontSize: Dimensions.FONT_SIZE_LARGE,
//                     ),
//                   ),
//                 )
//               : ListView.builder(
//                   primary: false,
//                   shrinkWrap: true,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: Dimensions.PADDING_SIZE_SMALL,
//                   ),
//                   itemCount: donationController.paymentListData?.data?.length,
//                   itemBuilder: (context, index) {
//                     var apiData =
//                         donationController.paymentListData?.data![index];
//                     return GestureDetector(
//                       onTap: () {
//                         donationController.setPaymentGatewayValue(
//                           apiData.type,
//                           apiData.apiKey,
//                           apiData.apiSecret,
//                           donationCatagoryId,
//                           apiData.id,
//                           apiData.paymentMode,
//                         );

//                         showModalBottomSheet(
//                           // backgroundColor: Theme.of(context).cardColor,
//                           clipBehavior: Clip.antiAlias,
//                           enableDrag: false,
//                           isDismissible: false,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(
//                                 Dimensions.RADIUS_EXTRA_LARGE,
//                               ),
//                               topRight: Radius.circular(
//                                 Dimensions.RADIUS_EXTRA_LARGE,
//                               ),
//                             ),
//                           ),
//                           context: context,
//                           isScrollControlled: true,
//                           builder: (BuildContext context) {
//                             return Padding(
//                               padding: EdgeInsets.only(
//                                 bottom: MediaQuery.of(
//                                   context,
//                                 ).viewInsets.bottom,
//                               ),
//                               child: PaymentBottomSheetScreen(
//                                 name: "${apiData.name}",
//                                 type: "${apiData.type}",
//                               ),
//                             );
//                           },
//                         );
//                       },
//                       child: Card(
//                         clipBehavior: Clip.antiAlias,
//                         color: Theme.of(context).cardColor,
//                         shadowColor: Get.isDarkMode
//                             ? Colors.grey[800]!
//                             : Colors.grey[200]!,
//                         child: ListTile(
//                           contentPadding: const EdgeInsetsDirectional.only(
//                             end: 0,
//                           ),
//                           // contentPadding: const EdgeInsetsDirectional.only(
//                           //    start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
//                           //    end: Dimensions.PADDING_SIZE_SMALL),
//                           leading: Padding(
//                             padding: const EdgeInsets.only(left: 10.0),
//                             child: Image.asset(
//                               apiData!.type == "paypal"
//                                   ? Images.Icon_Paypal
//                                   : apiData.type == "stripe"
//                                   ? Images.Icon_Stripe
//                                   : apiData.type == "paystack"
//                                   ? Images.Icon_Paystack
//                                   : apiData.type == "razorpay"
//                                   ? Images.Icon_Razorpay
//                                   : apiData.type == "sslcommerz"
//                                   ? Images.Icon_SSLCommerz
//                                   : Images.Icon_Haram,
//                               height: 25,
//                               fit: BoxFit.fill,
//                             ),
//                           ),
//                           title: Text(
//                             '${apiData.name}',
//                             style: robotoMedium.copyWith(
//                               fontSize: Get.find<SettingsController>()
//                                   .translateFontSize
//                                   .value,
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//         },
//       ),
//     );
//   }
// }
