import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/theme/light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_button.dart';
import '../../../controller/islamic_name_controller.dart';
import '../../../controller/quran_settings_controller.dart';
import '../../../data/model/response/islamic_name_model.dart';
import 'widget/build_feature_card.dart';

class IslamicNameGeneratorScreen extends StatelessWidget {
  final bool appBackButton;
  const IslamicNameGeneratorScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    // Put controller when screen opens, delete when screen closes
    final ctrl = Get.put(IslamicNameController());

    return Scaffold(
      appBar: CustomAppBar(
        isBackButtonExist: true,
        title: 'app_title'.tr,
        actions: [
          Obx(() {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: AppColor.cardColor,
                  ),
                  onPressed: () => _showFavorites(context, ctrl),
                ),
                if (ctrl.favorites.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ctrl.favorites.length > 9
                            ? '9+'
                            : '${ctrl.favorites.length}',
                        style: robotoMedium.copyWith(
                          color: AppColor.cardColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildFilterCard(context, ctrl),
            const SizedBox(height: 12),
            _buildGenerateButton(context, ctrl),
            const SizedBox(height: 20),
            Obx(() {
              if (ctrl.isLoading.value) return _buildLoader(context);
              if (ctrl.error.value != null) {
                return _buildError(context, ctrl);
              }
              if (ctrl.featured.value != null) {
                return FadeTransition(
                  opacity: ctrl.fadeAnim,
                  child: Column(
                    children: [
                      buildFeaturedCard(context, ctrl, ctrl.featured.value!),
                      const SizedBox(height: 12),
                      if (ctrl.names.length > 1) _buildNameGrid(context, ctrl),
                    ],
                  ),
                );
              }
              return _buildEmptyState(context);
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'bismillah'.tr,
            style: Get.find<SettingsController>().selectedArabicFont.copyWith(
              fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
              color: AppColor.cardColor,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Filter Card ───────────────────────────────
  Widget _buildFilterCard(BuildContext context, IslamicNameController ctrl) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'preferences'.tr,
              style: robotoMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildDropdown(
                      context,
                      label: 'gender'.tr,
                      value: ctrl.gender.value,
                      items: {
                        'any': 'gender_any'.tr,
                        'boy': 'Boy (ذكر)',
                        'girl': 'Girl (أنثى)',
                      },
                      onChanged: (v) => ctrl.gender.value = v!,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => _buildDropdown(
                      context,
                      label: 'origin'.tr,
                      value: ctrl.origin.value,
                      items: const {
                        'any': 'Any Origin',
                        'arabic': 'Arabic',
                        'bangla': 'Bangla',
                        'quranic': 'Quranic',
                        'persian': 'Persian',
                        'urdu': 'Urdu',
                      },
                      onChanged: (v) => ctrl.origin.value = v!,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    context,
                    controller: ctrl.themeCtrl,
                    label: 'synonyms_key'.tr,
                    hint: 'meaning_theme_hint'.tr,
                    icon: Icons.lightbulb_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    context,
                    controller: ctrl.letterCtrl,
                    label: 'starts_with'.tr,
                    hint: 'starts_with_hint'.tr,
                    icon: Icons.sort_by_alpha,
                    maxLength: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          items: items.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            prefixIcon: Icon(icon, size: 16, color: Colors.grey),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  // ── Generate Button ───────────────────────────
  Widget _buildGenerateButton(
    BuildContext context,
    IslamicNameController ctrl,
  ) {
    return Obx(
      () => CustomButton(
        buttonWidth: double.infinity,
        buttonName: ctrl.isLoading.value
            ? 'generating'.tr
            : 'generate_button'.tr,
        onPressed: ctrl.isLoading.value ? () {} : () => ctrl.generate(context),
      ),
    );
  }

  // ── Name Grid ─────────────────────────────────
  Widget _buildNameGrid(BuildContext context, IslamicNameController ctrl) {
    return Obx(() {
      final rest = ctrl.names.skip(1).toList();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.55,
        ),
        itemCount: rest.length,
        itemBuilder: (_, i) => _buildNameTile(context, ctrl, rest[i]),
      );
    });
  }

  Widget _buildNameTile(
    BuildContext context,
    IslamicNameController ctrl,
    IslamicName name,
  ) {
    return Obx(() {
      final isSelected = ctrl.featured.value?.english == name.english;
      return GestureDetector(
        onTap: () => ctrl.selectFeatured(name),
        onLongPress: () => ctrl.copyName(context, name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2.5 : 0.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    name.arabic,
                    textDirection: TextDirection.rtl,
                    style: Get.find<SettingsController>().selectedArabicFont.copyWith(
                      fontSize: 22,
                      color: Theme.of(context).primaryColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Text(
                name.english,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.FONT_SIZE_LARGE,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                name.meaning,
                style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              if (name.quranicReference != null &&
                  name.quranicReference != 'null' &&
                  name.quranicReference!.trim().isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 10, color: AppColor.goldColor),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        name.quranicReference.toString(),
                        style: robotoRegular.copyWith(
                          fontSize: 10,
                          color: AppColor.goldColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  // ── Loader ────────────────────────────────────
  Widget _buildLoader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 14),
          Text(
            'searching'.tr,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'please_wait'.tr,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────
  Widget _buildError(BuildContext context, IslamicNameController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'something_wrong'.tr,
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'unable_generate'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              buttonWidth: double.infinity,
              buttonName: "try_again".tr,
              onPressed: () => ctrl.generate(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.mosque, size: 48, color: Theme.of(context).primaryColor),
          const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          Text(
            'set_preferences'.tr,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'free_no_billing'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.FONT_SIZE_DEFAULT,
            ),
          ),
        ],
      ),
    );
  }

  // ── Favorites Bottom Sheet ────────────────────
  void _showFavorites(BuildContext context, IslamicNameController ctrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, scrollCtrl) => Obx(
          () => Column(
            children: [
              // ── Drag handle ──────────────────
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Title ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${'saved_names'.tr} (${ctrl.favorites.length})',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),

              // ── Empty state ──────────────────
              if (ctrl.favorites.isEmpty)
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'no_saved_names'.tr,
                    textAlign: TextAlign.center,
                    style: robotoMedium.copyWith(color: Colors.grey),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ctrl.favorites.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = ctrl.favorites[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // ── Arabic avatar ────────────────
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  n.english.characters.first,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                    color: AppColor.cardColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // ── Name details ─────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // English + Arabic on same row
                                  Row(
                                    children: [
                                      Text(
                                        n.english,
                                        style: robotoMedium.copyWith(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        n.arabic,
                                        style: Get.find<SettingsController>()
                                            .selectedArabicFont
                                            .copyWith(fontSize: 12),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  // Meaning
                                  Text(
                                    n.meaning,
                                    style: robotoRegular.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Quranic reference (if any)
                                  if (n.quranicReference != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.menu_book,
                                            size: 11,
                                            color: AppColor.goldColor,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              n.quranicReference!,
                                              style: robotoRegular.copyWith(
                                                fontSize: 11,
                                                color: AppColor.goldColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // ── Action buttons ───────────────
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Copy button
                                IconButton(
                                  icon: Icon(
                                    Icons.copy,
                                    size: 18,
                                    color: Get.isDarkMode
                                        ? AppColor.cardColor
                                        : Colors.grey,
                                  ),
                                  tooltip: 'copy'.tr,
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  onPressed: () => ctrl.copyName(context, n),
                                ),
                                // Delete button
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  tooltip: 'remove'.tr,
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  onPressed: () {
                                    ctrl.removeFavorite(n);
                                    Get.back();
                                    if (ctrl.favorites.isNotEmpty) {
                                      _showFavorites(context, ctrl);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
