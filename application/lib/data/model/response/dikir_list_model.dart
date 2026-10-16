class DikirListModel {
  bool? status;
  String? message;
  List<Data>? data;

  DikirListModel({this.status, this.message, this.data});

  DikirListModel.fromJson(Map<String, dynamic> json) {
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
  String? enShortName;
  String? arShortName;

  Data({this.id, this.enShortName, this.arShortName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    enShortName = json['en_short_name'];
    arShortName = json['ar_short_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['en_short_name'] = enShortName;
    data['ar_short_name'] = arShortName;
    return data;
  }
}
