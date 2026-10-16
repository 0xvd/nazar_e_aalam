class MosqueSettingsModel {
  bool? status;
  String? message;
  Data? data;

  MosqueSettingsModel({this.status, this.message, this.data});

  MosqueSettingsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? mosqueName;
  String? mosqueAddress;
  String? appLogo;
  String? googleMapKey;
  dynamic zakatNisab;
  String? zakatDescription;
  String? haramDescription;
  bool? automaticPayerTime;
  bool? ramadanSchedule;
  String? currencySymbol;
  String? playStoreUrl;
  String? appStoreUrl;
  String? donationBanner;
  bool? showDonationBanner;
  bool? showBannerIcon;
  String? islamicNameApiKey;
  String? homeLayout;

  Data({
    this.mosqueName,
    this.mosqueAddress,
    this.appLogo,
    this.googleMapKey,
    this.zakatNisab,
    this.zakatDescription,
    this.haramDescription,
    this.automaticPayerTime,
    this.ramadanSchedule,
    this.currencySymbol,
    this.playStoreUrl,
    this.appStoreUrl,
    this.donationBanner,
    this.showDonationBanner,
    this.showBannerIcon,
    this.islamicNameApiKey,
    this.homeLayout,
  });

  Data.fromJson(Map<String, dynamic> json) {
    mosqueName = json['mosque_name'];
    mosqueAddress = json['mosque_address'];
    appLogo = json['app_logo'];
    googleMapKey = json['google_map_key'];
    zakatNisab = json['zakat_nisab'];
    zakatDescription = json['zakat_description'];
    haramDescription = json['haram_description'];
    automaticPayerTime = json['automatic_payer_time'];
    ramadanSchedule = json['ramadan_schedule'];
    currencySymbol = json['currency_symbol'];
    playStoreUrl = json['play_store_url'];
    appStoreUrl = json['app_store_url'];
    donationBanner = json['donation_banner'];
    showDonationBanner = json['show_donation_banner'];
    showBannerIcon = json['show_donation_icon'];
    islamicNameApiKey = json['islamic_name_api_key'];
    homeLayout = json['home_layout'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mosque_name'] = mosqueName;
    data['mosque_address'] = mosqueAddress;
    data['app_logo'] = appLogo;
    data['google_map_key'] = googleMapKey;
    data['zakat_nisab'] = zakatNisab;
    data['zakat_description'] = zakatDescription;
    data['haram_description'] = haramDescription;
    data['automatic_payer_time'] = automaticPayerTime;
    data['ramadan_schedule'] = ramadanSchedule;
    data['currency_symbol'] = currencySymbol;
    data['play_store_url'] = playStoreUrl;
    data['app_store_url'] = appStoreUrl;
    data['donation_banner'] = donationBanner;
    data['show_donation_banner'] = showDonationBanner;
    data['show_donation_icon'] = showBannerIcon;
    data['islamic_name_api_key'] = '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';
    data['home_layout'] = homeLayout;
    return data;
  }
}
