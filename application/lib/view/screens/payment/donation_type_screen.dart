// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/helper/route_helper.dart';
// import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
// import '../../../controller/donation_controller.dart';
// import '../../../controller/quran_settings_controller.dart';
// import '../../../util/dimensions.dart';
// import '../../../util/images.dart';
// import '../../../util/styles.dart';
// import '../../base/custom_app_bar.dart';

// class DonationTypeScreen extends StatefulWidget {
//   final bool appBackButton;

//   const DonationTypeScreen({super.key, required this.appBackButton});

//   @override
//   State<DonationTypeScreen> createState() => _DonationTypeScreenState();
// }

// class _DonationTypeScreenState extends State<DonationTypeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     Get.find<DonationController>().donationCategoryListData();
//     return Scaffold(
//       // Appbar start ===>
//       appBar: CustomAppBar(
//         title: "donation_type".tr,
//         isBackButtonExist: widget.appBackButton == true ? true : false,
//       ),

//       // body start ===>
//       body: GetBuilder<DonationController>(
//         builder: (categoryListController) {
//           return categoryListController.isCategoryListLoading.value ||
//                   categoryListController.donationCategoryData == null
//               ? const Center(
//                   child: DonationTypeShimmer(),
//                 )
//               : ListView.builder(
//                   primary: false,
//                   shrinkWrap: true,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: Dimensions.PADDING_SIZE_SMALL),
//                   itemCount:
//                       categoryListController.donationCategoryData?.data?.length,
//                   itemBuilder: (context, index) {
//                     var apiData = categoryListController
//                         .donationCategoryData?.data![index];
//                     return GestureDetector(
//                       onTap: () {
//                         Get.toNamed(
//                           RouteHelper.paymentType,
//                           arguments: apiData.id,
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
//                               start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
//                               end: Dimensions.PADDING_SIZE_SMALL),
//                           leading: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               SvgPicture.asset(
//                                 Images.Icon_Star,
//                                 height: 50,
//                                 fit: BoxFit.fill,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               Text(
//                                 apiData!.id.toString(),
//                                 style: robotoMedium.copyWith(
//                                   fontSize: Dimensions.FONT_SIZE_SMALL,
//                                   color: Theme.of(context)
//                                       .textTheme
//                                       .bodyMedium!
//                                       .color,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           title: Text(
//                             apiData.name.toString(),
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
