// // ignore_for_file: must_be_immutable, deprecated_member_use

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

// class HadisBookNameScreen extends StatelessWidget {
//   final bool appBackButton;
//   HadisBookNameScreen({super.key, required this.appBackButton});
//   HadithController hadithController = Get.put(HadithController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Appbar start ===>
//       appBar: CustomAppBar(
//         title: "hadith_books".tr,
//         isBackButtonExist: appBackButton == true ? true : false,
//       ),

//       // body start ===>
//       body: GetBuilder<HadithController>(
//         init: HadithController(),
//         builder: (_) {
//           return hadithController.isLoadingHadithChapter.value
//               ? const Center(child: HadisBookShimmer())
//               : SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // list viwe start ===>
//                       ListView.builder(
//                         primary: false,
//                         shrinkWrap: true,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: Dimensions.PADDING_SIZE_SMALL),
//                         itemCount: 6,
//                         itemBuilder: (context, index) {
//                           return GestureDetector(
//                             onTap: () {
//                               Get.toNamed(RouteHelper.hadithChapters,
//                                   arguments: [
//                                     hadithController
//                                         .hadisBookModel!.books![index].bookSlug,
//                                     hadithController
//                                         .hadisBookModel!.books![index].bookName
//                                   ]);
//                             },
//                             child: Card(
//                               clipBehavior: Clip.antiAlias,
//                               color: Theme.of(context).cardColor,
//                               child: ListTile(
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     horizontal:
//                                         Dimensions.PADDING_SIZE_EXTRA_SMALL + 2,
//                                     vertical:
//                                         Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                                 horizontalTitleGap: 0,
//                                 leading: SvgPicture.asset(
//                                   Images.Icon_Hadith,
//                                   color: Theme.of(context).primaryColor,
//                                   height: 50,
//                                 ),
//                                 title: Text(
//                                   hadithController
//                                       .hadisBookModel!.books![index].bookName!,
//                                   style: robotoMedium.copyWith(
//                                       fontSize: Dimensions.FONT_SIZE_LARGE),
//                                 ),
//                                 subtitle: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const SizedBox(height: 5),
//                                     Text(
//                                       hadithController.hadisBookModel!
//                                           .books![index].writerName!,
//                                       textAlign: TextAlign.left,
//                                       style: robotoMedium.copyWith(
//                                           fontSize:
//                                               Dimensions.FONT_SIZE_DEFAULT),
//                                     ),
//                                     const SizedBox(height: 5),
//                                     Text(
//                                       "${"hadiths".tr}: ${hadithController.hadisBookModel!.books![index].hadithsCount!}",
//                                       style: robotoMedium.copyWith(
//                                           fontSize: Dimensions.FONT_SIZE_SMALL),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//         },
//       ),
//     );
//   }
// }
