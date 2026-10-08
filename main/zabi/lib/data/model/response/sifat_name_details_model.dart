class SifatNameDetailsModel {
  bool? status;
  String? message;
  Data? data;

  SifatNameDetailsModel({this.status, this.message, this.data});

  SifatNameDetailsModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? enName;
  String? arName;
  String? translatedName;
  String? meaning;
  String? nameBenefits;

  Data(
      {this.id,
      this.enName,
      this.arName,
      this.translatedName,
      this.meaning,
      this.nameBenefits});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enName = json['en_name'];
    arName = json['ar_name'];
    translatedName = json['translated_name'];
    meaning = json['meaning'];
    nameBenefits = json['name_benefits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['en_name'] = enName;
    data['ar_name'] = arName;
    data['translated_name'] = translatedName;
    data['meaning'] = meaning;
    data['name_benefits'] = nameBenefits;
    return data;
  }
}
