class SuraListModel {
  bool? status;
  String? message;
  List<Data>? data;

  SuraListModel({this.status, this.message, this.data});

  SuraListModel.fromJson(Map<String, dynamic> json) {
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
  String? serialNumber;
  String? arabicName;
  String? translateName;
  String? versesTranslateName;
  String? versesCount;

  Data(
      {this.id,
      this.serialNumber,
      this.arabicName,
      this.translateName,
      this.versesTranslateName,
      this.versesCount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serial_number'];
    arabicName = json['arabic_name'];
    translateName = json['translate_name'];
    versesTranslateName = json['verses_translate_name'];
    versesCount = json['verses_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['serial_number'] = serialNumber;
    data['arabic_name'] = arabicName;
    data['translate_name'] = translateName;
    data['verses_translate_name'] = versesTranslateName;
    data['verses_count'] = versesCount;
    return data;
  }
}
