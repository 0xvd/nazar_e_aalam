// // ignore_for_file: deprecated_member_use

// import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/data/model/response/hadith_model.dart';
// import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
// import '../../../util/dimensions.dart';
// import '../../../util/images.dart';
// import '../../../util/styles.dart';

// class HadithDetailsScreen extends StatelessWidget {
//   final bool appBackButton;
//   HadithDetailsScreen({super.key, required this.appBackButton});

//   final Data data = Get.arguments;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Appbar start ===>
//       appBar: CustomAppBar(
//         title: "hadith_details".tr,
//         isBackButtonExist: appBackButton == true ? true : false,
//       ),

//       // start body ===>
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//               horizontal: Dimensions.PADDING_SIZE_DEFAULT),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // bismillah image ==>
//               Padding(
//                 padding:
//                     const EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
//                 child: SizedBox(
//                   height: 50,
//                   width: double.infinity,
//                   child: SvgPicture.asset(
//                     Images.Bismillah,
//                     height: 50,
//                     fit: BoxFit.fitHeight,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//               const Divider(),
//               Center(
//                 child: Text(
//                   "hadith_arabic".tr,
//                   style: robotoMedium.copyWith(
//                       fontSize: Dimensions.FONT_SIZE_DEFAULT),
//                 ),
//               ),
//               const Divider(),
//               const SizedBox(
//                 height: 20,
//               ),
//               // arabic data ==>
//               Text(
//                 data.hadithArabic.toString(),
//                 textAlign: TextAlign.right,
//                 style: Get.find<SettingsController>()
//                     .selectedArabicFont
//                     .copyWith(
//                   fontSize: Get.find<SettingsController>().arabicFontSize.value,
//                   color: Theme.of(context).textTheme.bodyLarge!.color,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Divider(),
//               Center(
//                 child: Text(
//                   "hadith_english".tr,
//                   style: robotoMedium.copyWith(
//                       fontSize: Dimensions.FONT_SIZE_DEFAULT),
//                 ),
//               ),
//               const Divider(),
//               const SizedBox(height: 20),

//               // english data==>
//               Text(
//                 data.hadithEnglish.toString(),
//                 textAlign: TextAlign.justify,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               const Divider(),
//               const SizedBox(height: 10),

//               // hadith all info ===>
//               Text(
//                 "${"hadith_number".tr}: ${data.hadithNumber}",
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 "${"book_name".tr}: ${data.book!.bookName!}".tr,
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 "${"writer_name".tr}: ${data.book!.writerName}",
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 "${"writer_death".tr}: ${data.book!.writerDeath!}",
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 "${"chapter_number".tr}: ${data.chapter!.chapterNumber!}",
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 "${"chapter_name".tr}: ${data.chapter!.chapterEnglish!}",
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 "${"english_narrator".tr}: ${data.englishNarrator}",
//                 textAlign: TextAlign.left,
//                 style: robotoMedium.copyWith(
//                     fontSize: Dimensions.FONT_SIZE_DEFAULT),
//               ),
//               const SizedBox(height: 10),
//               const Divider(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
