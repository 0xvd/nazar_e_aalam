import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/util/images.dart';

/// One tappable feature (Quran, Dua, Zakat...).
class FeatureItem {
  final String titleKey;
  final String icon;
  final String route;
  const FeatureItem({
    required this.titleKey,
    required this.icon,
    required this.route,
  });
}

/// Edit THIS list to add/remove features everywhere (home, category page).
/// Flat list — no sections, no Worship/Tools/More partitions.
class FeatureItems {
  static List<FeatureItem> all() => [
        FeatureItem(
            titleKey: 'quran',
            icon: Images.Icon_Quran,
            route: RouteHelper.suraList),
        FeatureItem(
            titleKey: 'audio_quran',
            icon: Images.Iocn_Audio,
            route: RouteHelper.recters),
        FeatureItem(
            titleKey: 'dikir', icon: Images.Icon_Dikir, route: RouteHelper.dhikr),
        FeatureItem(titleKey: 'dua', icon: Images.Icon_Dua, route: RouteHelper.dua),
        FeatureItem(
            titleKey: 'hadith',
            icon: Images.Icon_Hadith,
            route: RouteHelper.hadithBookName),
        FeatureItem(
            titleKey: 'allah_name',
            icon: Images.Icon_Allah_99_name,
            route: RouteHelper.sifatName),
        FeatureItem(
            titleKey: 'compass', icon: Images.Icon_Qibla, route: RouteHelper.compass),
        FeatureItem(
            titleKey: 'nearby',
            icon: Images.Icon_near_mosque,
            route: RouteHelper.nearByMosque),
        FeatureItem(
            titleKey: 'zakat_calculator',
            icon: Images.Icon_Zakat,
            route: RouteHelper.zakatCalculator),
        FeatureItem(
            titleKey: 'haram_codes',
            icon: Images.Icon_Haram,
            route: RouteHelper.haramIngredientsFood),
        FeatureItem(
            titleKey: 'alphabet_key',
            icon: Images.Icon_Alif,
            route: RouteHelper.alphabetScreens),
        FeatureItem(
            titleKey: 'wallpapers_key',
            icon: Images.wallpaper,
            route: RouteHelper.wallpaperScreens),
        FeatureItem(
            titleKey: 'settings',
            icon: Images.Icon_app_setting,
            route: RouteHelper.settings),
      ];
}
