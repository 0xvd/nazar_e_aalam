class JuzListModel {
  bool? status;
  String? message;
  List<Data>? data;

  JuzListModel({this.status, this.message, this.data});

  JuzListModel.fromJson(Map<String, dynamic> json) {
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
  String? juzNumber;
  String? juzTranslateName;
  List<ChapterList>? chapterList;

  Data({this.juzNumber, this.juzTranslateName, this.chapterList});

  Data.fromJson(Map<String, dynamic> json) {
    juzNumber = json['juz_number'];
    juzTranslateName = json['juz_translate_name'];
    if (json['chapter_list'] != null) {
      chapterList = <ChapterList>[];
      json['chapter_list'].forEach((v) {
        chapterList!.add(ChapterList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['juz_number'] = juzNumber;
    data['juz_translate_name'] = juzTranslateName;
    if (chapterList != null) {
      data['chapter_list'] = chapterList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChapterList {
  int? chapterId;
  String? serialNumber;
  String? arabicName;
  String? translatedName;
  String? versesTranslateName;
  String? verseNumber;

  ChapterList(
      {this.chapterId,
      this.serialNumber,
      this.arabicName,
      this.translatedName,
      this.versesTranslateName,
      this.verseNumber});

  ChapterList.fromJson(Map<String, dynamic> json) {
    chapterId = json['chapter_id'];
    serialNumber = json['serial_number'];
    arabicName = json['arabic_name'];
    translatedName = json['translated_name'];
    versesTranslateName = json['verses_translate_name'];
    verseNumber = json['verse_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chapter_id'] = chapterId;
    data['serial_number'] = serialNumber;
    data['arabic_name'] = arabicName;
    data['translated_name'] = translatedName;
    data['verses_translate_name'] = versesTranslateName;
    data['verse_number'] = verseNumber;
    return data;
  }
}
