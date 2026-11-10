import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/feature_grid.dart';

/// Kept so existing routes still work. All features now live on the home
/// page; this screen just shows the same grouped grid. Safe to delete later.
class CategoryScreen extends StatelessWidget {
  final bool appBackButton;
  const CategoryScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final modern = Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'all_category',
        isBackButtonExist: appBackButton,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16),
        child: FeatureGrid(modern: modern),
      ),
    );
  }
}