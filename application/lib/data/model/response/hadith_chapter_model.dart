class HadithChapterModel {
  HadithChapterModel({
    this.status,
    this.message,
    this.chapters,
  });

  HadithChapterModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['chapters'] != null) {
      chapters = [];
      json['chapters'].forEach((v) {
        chapters?.add(Chapters.fromJson(v));
      });
    }
  }
  num? status;
  String? message;
  List<Chapters>? chapters;
  HadithChapterModel copyWith({
    num? status,
    String? message,
    List<Chapters>? chapters,
  }) =>
      HadithChapterModel(
        status: status ?? this.status,
        message: message ?? this.message,
        chapters: chapters ?? this.chapters,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (chapters != null) {
      map['chapters'] = chapters?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Chapters {
  Chapters({
    this.id,
    this.chapterNumber,
    this.chapterEnglish,
    this.chapterUrdu,
    this.chapterArabic,
    this.bookSlug,
  });

  Chapters.fromJson(dynamic json) {
    id = json['id'];
    chapterNumber = json['chapterNumber'];
    chapterEnglish = json['chapterEnglish'];
    chapterUrdu = json['chapterUrdu'];
    chapterArabic = json['chapterArabic'];
    bookSlug = json['bookSlug'];
  }
  num? id;
  num? chapterNumber;
  String? chapterEnglish;
  String? chapterUrdu;
  String? chapterArabic;
  String? bookSlug;
  Chapters copyWith({
    num? id,
    num? chapterNumber,
    String? chapterEnglish,
    String? chapterUrdu,
    String? chapterArabic,
    String? bookSlug,
  }) =>
      Chapters(
        id: id ?? this.id,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        chapterEnglish: chapterEnglish ?? this.chapterEnglish,
        chapterUrdu: chapterUrdu ?? this.chapterUrdu,
        chapterArabic: chapterArabic ?? this.chapterArabic,
        bookSlug: bookSlug ?? this.bookSlug,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['chapterNumber'] = chapterNumber;
    map['chapterEnglish'] = chapterEnglish;
    map['chapterUrdu'] = chapterUrdu;
    map['chapterArabic'] = chapterArabic;
    map['bookSlug'] = bookSlug;
    return map;
  }
}
