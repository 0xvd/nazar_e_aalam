class DuaDetailsModel {
  bool? status;
  String? message;
  Data? data;

  DuaDetailsModel({this.status, this.message, this.data});

  DuaDetailsModel.fromJson(Map<String, dynamic> json) {
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
  String? arShortName;
  String? arFullName;
  String? enShortName;
  String? enFullName;

  Data(
      {this.id,
      this.arShortName,
      this.arFullName,
      this.enShortName,
      this.enFullName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    arShortName = json['ar_short_name'];
    arFullName = json['ar_full_name'];
    enShortName = json['en_short_name'];
    enFullName = json['en_full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ar_short_name'] = arShortName;
    data['ar_full_name'] = arFullName;
    data['en_short_name'] = enShortName;
    data['en_full_name'] = enFullName;
    return data;
  }
}
