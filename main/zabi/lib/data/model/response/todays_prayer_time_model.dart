class PrayerTimeModel {
  bool? status;
  String? message;
  Data? data;

  PrayerTimeModel({this.status, this.message, this.data});

  PrayerTimeModel.fromJson(Map<String, dynamic> json) {
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
  String? date;
  bool? isJumma;
  String? imsak;
  String? fajrStart;
  String? sunrise;
  String? zuhrStart;
  String? asrStart;
  String? maghribStart;
  String? ishaStart;
  String? sehriEnd;
  String? iftarStart;

  Data({
    this.date,
    this.isJumma,
    this.imsak,
    this.fajrStart,
    this.sunrise,
    this.zuhrStart,
    this.asrStart,
    this.maghribStart,
    this.ishaStart,
    this.sehriEnd,
    this.iftarStart,
  });

  Data.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    isJumma = json['is_jumma'];
    imsak = json['imsak'];
    fajrStart = json['fajr_start'];
    sunrise = json['sunrise'];
    zuhrStart = json['zuhr_start'];
    asrStart = json['asr_start'];
    maghribStart = json['maghrib_start'];
    ishaStart = json['isha_start'];
    sehriEnd = json['sehri'];
    iftarStart = json['iftar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['is_jumma'] = isJumma;
    data['imsak'] = imsak;
    data['fajr_start'] = fajrStart;
    data['sunrise'] = sunrise;
    data['zuhr_start'] = zuhrStart;
    data['asr_start'] = asrStart;
    data['maghrib_start'] = maghribStart;
    data['isha_start'] = ishaStart;
    data['sehri'] = sehriEnd;
    data['iftar'] = iftarStart;
    return data;
  }
}
