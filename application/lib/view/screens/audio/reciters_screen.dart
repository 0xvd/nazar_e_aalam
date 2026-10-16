// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/audio_player_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

class ReciterScreen extends StatelessWidget {
  final bool? appBackButton;
  ReciterScreen({super.key, this.appBackButton});

  final AudioPlayerController audioPlayerController =
      Get.put(AudioPlayerController(apiClient: Get.find()));

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      audioPlayerController.fetchReciterData();
    });

    return Scaffold(
      // Appbar start
      appBar: CustomAppBar(
        title: "all_reciters_key".tr,
        isBackButtonExist: appBackButton == true ? true : false,
      ),

      // body start
      body: GetBuilder<AudioPlayerController>(
        builder: (audioPlayerController) {
          return audioPlayerController.isRecitersLoading.value ||
                  audioPlayerController.recitersListApiData == null
              ? const Center(child: DhuaShimmer())
              : ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.PADDING_SIZE_SMALL),
                  itemCount:
                      audioPlayerController.recitersListApiData!.data!.length,
                  itemBuilder: (context, index) {
                    final reciter =
                        audioPlayerController.recitersListApiData!.data![index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteHelper.audioList,
                            arguments: reciter.id);
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        color: Theme.of(context).cardColor,
                        shadowColor: Get.isDarkMode
                            ? Colors.grey[800]!
                            : Colors.grey[200]!,
                        child: ListTile(
                          contentPadding: const EdgeInsetsDirectional.only(
                              start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                              end: Dimensions.PADDING_SIZE_SMALL),
                          leading: CircleAvatar(
                              backgroundImage: reciter.profilePicture != null
                                  ? NetworkImage(
                                      reciter.profilePicture.toString())
                                  : AssetImage(Images.Reciter_Person)),
                          title: Text(
                            reciter.name ?? 'no_name_found_key'.tr,
                            style: robotoMedium.copyWith(),
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
