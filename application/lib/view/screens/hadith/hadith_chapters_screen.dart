// // ignore_for_file: deprecated_member_use

// import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
// import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
// import '../../../controller/hadith_controller.dart';
// import '../../../helper/route_helper.dart';
// import '../../../util/dimensions.dart';
// import '../../../util/images.dart';
// import '../../../util/styles.dart';

// class HadithChaptersScreen extends StatefulWidget {
//   final bool appBackButton;
//   const HadithChaptersScreen({super.key, required this.appBackButton});

//   @override
//   State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
// }

// class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
//   HadithController hadithController = Get.put(HadithController());

//   @override
//   void initState() {
//     // print("Init state method is called");
//     hadithController.getHadithBookChaptersData(Get.arguments[0]);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Appbar start ===>
//       appBar: CustomAppBar(
//         title: "${Get.arguments[1]} ${"chapters".tr}",
//         isBackButtonExist: widget.appBackButton == true ? true : false,
//       ),

//       // start body ===>
//       body: GetBuilder<HadithController>(
//         builder: (_) {
//           return hadithController.isLoadingHadithChapter.value
//               ? const Center(child: HadisChapterShimmer())
//               : SingleChildScrollView(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     primary: false,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: Dimensions.PADDING_SIZE_SMALL),
//                     itemCount:
//                         hadithController.hadithChapterModel!.chapters!.length,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           Get.toNamed(RouteHelper.allHadith, arguments: [
//                             Get.arguments[1],
//                             hadithController
//                                 .hadithChapterModel!.chapters![index].bookSlug,
//                             hadithController.hadithChapterModel!
//                                 .chapters![index].chapterNumber,
//                           ]);
//                         },
//                         child: Card(
//                           clipBehavior: Clip.antiAlias,
//                           color: Theme.of(context).cardColor,
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal:
//                                     Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                             horizontalTitleGap: 5,
//                             leading: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 // bismillah image ===>
//                                 SvgPicture.asset(
//                                   Images.Icon_Star,
//                                   height: 50,
//                                   fit: BoxFit.fill,
//                                   color: Theme.of(context).primaryColor,
//                                 ),

//                                 // serial number show ===>
//                                 Text(
//                                   hadithController.hadithChapterModel!
//                                       .chapters![index].chapterNumber
//                                       .toString(),
//                                   style: robotoMedium.copyWith(
//                                     fontSize: Dimensions.FONT_SIZE_DEFAULT,
//                                     color: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium!
//                                         .color,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             title: Text(
//                               hadithController.hadithChapterModel!
//                                   .chapters![index].chapterArabic
//                                   .toString(),
//                               style: Get.find<SettingsController>()
//                                   .selectedArabicFont
//                                   .copyWith(
//                                 fontSize: Get.find<SettingsController>()
//                                     .arabicFontSize
//                                     .value,
//                                 color: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge!
//                                     .color,
//                               ),
//                             ),
//                             subtitle: Text(
//                               hadithController.hadithChapterModel!
//                                   .chapters![index].chapterEnglish
//                                   .toString(),
//                               style: robotoMedium.copyWith(
//                                 fontSize: Dimensions.FONT_SIZE_DEFAULT,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//         },
//       ),
//     );
//   }
// }
