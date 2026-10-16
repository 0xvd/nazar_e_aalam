class TranslatorModel {
  bool? status;
  String? message;
  List<Data>? data;

  TranslatorModel({this.status, this.message, this.data});

  TranslatorModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? fullName;
  String? shortName;
  String? language;
  String? languageCode;

  Data(
      {this.id,
      this.fullName,
      this.shortName,
      this.language,
      this.languageCode});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    shortName = json['short_name'];
    language = json['language'];
    languageCode = json['language_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['full_name'] = fullName;
    data['short_name'] = shortName;
    data['language'] = language;
    data['language_code'] = languageCode;
    return data;
  }
}
