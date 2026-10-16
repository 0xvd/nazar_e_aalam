class SuraDetaileModel {
  bool? status;
  String? message;
  Data? data;

  SuraDetaileModel({this.status, this.message, this.data});

  SuraDetaileModel.fromJson(Map<String, dynamic> json) {
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
  Chapter? chapter;
  List<ChapterInfo>? chapterInfo;

  Data({this.chapter, this.chapterInfo});

  Data.fromJson(Map<String, dynamic> json) {
    chapter = json['chapter'] != null
        ? Chapter.fromJson(json['chapter'])
        : null;
    if (json['chapter_info'] != null) {
      chapterInfo = <ChapterInfo>[];
      json['chapter_info'].forEach((v) {
        chapterInfo!.add(ChapterInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chapter != null) {
      data['chapter'] = chapter!.toJson();
    }
    if (chapterInfo != null) {
      data['chapter_info'] = chapterInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chapter {
  int? id;
  String? serialNumber;
  String? arabicName;
  String? translatedName;
  String? versesTranslateName;
  String? versesCount;

  Chapter({
    this.id,
    this.serialNumber,
    this.arabicName,
    this.translatedName,
    this.versesTranslateName,
    this.versesCount,
  });

  Chapter.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    serialNumber = parseString(json['serial_number']);
    arabicName = parseString(json['arabic_name']);
    translatedName = parseString(json['translated_name']);
    versesTranslateName = parseString(json['verses_translate_name']);
    versesCount = parseString(json['verses_count']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serial_number': serialNumber,
      'arabic_name': arabicName,
      'translated_name': translatedName,
      'verses_translate_name': versesTranslateName,
      'verses_count': versesCount,
    };
  }
}


class ChapterInfo {
  int? pageNumber;
  List<PageVerses>? pageVerses;
  String? pageArabicAyah;
  int? pageKey;
  int? engPageNumber;

  ChapterInfo({
    this.pageNumber,
    this.pageVerses,
    this.pageArabicAyah,
    this.pageKey,
    this.engPageNumber,
  });

  ChapterInfo.fromJson(Map<String, dynamic> json) {
    pageNumber = parseInt(json['page_number']);
    if (json['page_verses'] != null) {
      pageVerses = <PageVerses>[];
      json['page_verses'].forEach((v) {
        pageVerses!.add(PageVerses.fromJson(v));
      });
    }
    pageArabicAyah = json['page_arabic_ayah'];
    pageKey = parseInt(json['page_key']);
    engPageNumber = parseInt(json['eng_page_number']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page_number'] = pageNumber;
    if (pageVerses != null) {
      data['page_verses'] = pageVerses!.map((v) => v.toJson()).toList();
    }
    data['page_arabic_ayah'] = pageArabicAyah;
    data['page_key'] = pageKey;
    data['eng_page_number'] = engPageNumber;
    return data;
  }
}


class PageVerses {
  int? id;
  int? chapterId;
  String? versesTranslateName;
  int? versesNumber;
  String? arabicName;
  String? translatedName;
  String? transLiteration;

  PageVerses({
    this.id,
    this.chapterId,
    this.versesTranslateName,
    this.versesNumber,
    this.arabicName,
    this.translatedName,
    this.transLiteration,
  });

  PageVerses.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    chapterId = parseInt(json['chapter_id']);
    versesTranslateName = json['verses_translate_name'];
    versesNumber = parseInt(json['verses_number']);
    arabicName = json['arabic_name'];
    translatedName = json['translated_name'];
    transLiteration = json['english_transliteration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['chapter_id'] = chapterId;
    data['verses_translate_name'] = versesTranslateName;
    data['verses_number'] = versesNumber;
    data['arabic_name'] = arabicName;
    data['translated_name'] = translatedName;
    data['english_transliteration'] = transLiteration;
    return data;
  }
}

// Helper to safely parse dynamic int/string
int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}


String? parseString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}
