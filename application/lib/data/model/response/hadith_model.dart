class HadithModel {
  HadithModel({
    this.status,
    this.message,
    this.hadiths,
  });

  HadithModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    hadiths =
        json['hadiths'] != null ? Hadiths.fromJson(json['hadiths']) : null;
  }
  num? status;
  String? message;
  Hadiths? hadiths;
  HadithModel copyWith({
    num? status,
    String? message,
    Hadiths? hadiths,
  }) =>
      HadithModel(
        status: status ?? this.status,
        message: message ?? this.message,
        hadiths: hadiths ?? this.hadiths,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (hadiths != null) {
      map['hadiths'] = hadiths?.toJson();
    }
    return map;
  }
}

class Hadiths {
  Hadiths({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Hadiths.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = [];
      json['links'].forEach((v) {
        links?.add(Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }
  num? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  num? from;
  num? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  dynamic nextPageUrl;
  String? path;
  num? perPage;
  dynamic prevPageUrl;
  num? to;
  num? total;
  Hadiths copyWith({
    num? currentPage,
    List<Data>? data,
    String? firstPageUrl,
    num? from,
    num? lastPage,
    String? lastPageUrl,
    List<Links>? links,
    dynamic nextPageUrl,
    String? path,
    num? perPage,
    dynamic prevPageUrl,
    num? to,
    num? total,
  }) =>
      Hadiths(
        currentPage: currentPage ?? this.currentPage,
        data: data ?? this.data,
        firstPageUrl: firstPageUrl ?? this.firstPageUrl,
        from: from ?? this.from,
        lastPage: lastPage ?? this.lastPage,
        lastPageUrl: lastPageUrl ?? this.lastPageUrl,
        links: links ?? this.links,
        nextPageUrl: nextPageUrl ?? this.nextPageUrl,
        path: path ?? this.path,
        perPage: perPage ?? this.perPage,
        prevPageUrl: prevPageUrl ?? this.prevPageUrl,
        to: to ?? this.to,
        total: total ?? this.total,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['first_page_url'] = firstPageUrl;
    map['from'] = from;
    map['last_page'] = lastPage;
    map['last_page_url'] = lastPageUrl;
    if (links != null) {
      map['links'] = links?.map((v) => v.toJson()).toList();
    }
    map['next_page_url'] = nextPageUrl;
    map['path'] = path;
    map['per_page'] = perPage;
    map['prev_page_url'] = prevPageUrl;
    map['to'] = to;
    map['total'] = total;
    return map;
  }
}

class Links {
  Links({
    this.url,
    this.label,
    this.active,
    this.page,
  });

  Links.fromJson(dynamic json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
    page = json['page'];
  }

  dynamic url;
  dynamic label;   // ✅ was String? — API sends int OR String
  bool? active;
  num? page;       // ✅ new field, API sends int

  Links copyWith({
    dynamic url,
    dynamic label,
    bool? active,
    num? page,
  }) =>
      Links(
        url: url ?? this.url,
        label: label ?? this.label,
        active: active ?? this.active,
        page: page ?? this.page,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['label'] = label;
    map['active'] = active;
    map['page'] = page;
    return map;
  }
}

class Data {
  Data({
    this.id,
    this.hadithNumber,
    this.englishNarrator,
    this.hadithEnglish,
    this.hadithUrdu,
    this.urduNarrator,
    this.hadithArabic,
    this.chapterId,
    this.bookSlug,
    this.volume,
    this.book,
    this.chapter,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    hadithNumber = json['hadithNumber'];
    englishNarrator = json['englishNarrator'];
    hadithEnglish = json['hadithEnglish'];
    hadithUrdu = json['hadithUrdu'];
    urduNarrator = json['urduNarrator'];
    hadithArabic = json['hadithArabic'];
    chapterId = json['chapterId'];
    bookSlug = json['bookSlug'];
    volume = json['volume'];
    book = json['book'] != null ? Book.fromJson(json['book']) : null;
    chapter =
        json['chapter'] != null ? Chapter.fromJson(json['chapter']) : null;
  }
  num? id;
  String? hadithNumber;
  String? englishNarrator;
  String? hadithEnglish;
  String? hadithUrdu;
  String? urduNarrator;
  String? hadithArabic;
  num? chapterId;
  String? bookSlug;
  num? volume;
  Book? book;
  Chapter? chapter;
  Data copyWith({
    num? id,
    String? hadithNumber,
    String? englishNarrator,
    String? hadithEnglish,
    String? hadithUrdu,
    String? urduNarrator,
    String? hadithArabic,
    num? chapterId,
    String? bookSlug,
    num? volume,
    Book? book,
    Chapter? chapter,
  }) =>
      Data(
        id: id ?? this.id,
        hadithNumber: hadithNumber ?? this.hadithNumber,
        englishNarrator: englishNarrator ?? this.englishNarrator,
        hadithEnglish: hadithEnglish ?? this.hadithEnglish,
        hadithUrdu: hadithUrdu ?? this.hadithUrdu,
        urduNarrator: urduNarrator ?? this.urduNarrator,
        hadithArabic: hadithArabic ?? this.hadithArabic,
        chapterId: chapterId ?? this.chapterId,
        bookSlug: bookSlug ?? this.bookSlug,
        volume: volume ?? this.volume,
        book: book ?? this.book,
        chapter: chapter ?? this.chapter,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['hadithNumber'] = hadithNumber;
    map['englishNarrator'] = englishNarrator;
    map['hadithEnglish'] = hadithEnglish;
    map['hadithUrdu'] = hadithUrdu;
    map['urduNarrator'] = urduNarrator;
    map['hadithArabic'] = hadithArabic;
    map['chapterId'] = chapterId;
    map['bookSlug'] = bookSlug;
    map['volume'] = volume;
    if (book != null) {
      map['book'] = book?.toJson();
    }
    if (chapter != null) {
      map['chapter'] = chapter?.toJson();
    }
    return map;
  }
}

class Chapter {
  Chapter({
    this.id,
    this.chapterNumber,
    this.chapterEnglish,
    this.chapterUrdu,
    this.chapterArabic,
    this.bookSlug,
  });

  Chapter.fromJson(dynamic json) {
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
  Chapter copyWith({
    num? id,
    num? chapterNumber,
    String? chapterEnglish,
    String? chapterUrdu,
    String? chapterArabic,
    String? bookSlug,
  }) =>
      Chapter(
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

class Book {
  Book({
    this.id,
    this.bookName,
    this.writerName,
    this.aboutWriter,
    this.writerDeath,
    this.bookSlug,
  });

  Book.fromJson(dynamic json) {
    id = json['id'];
    bookName = json['bookName'];
    writerName = json['writerName'];
    aboutWriter = json['aboutWriter'];
    writerDeath = json['writerDeath'];
    bookSlug = json['bookSlug'];
  }
  num? id;
  String? bookName;
  String? writerName;
  dynamic aboutWriter;
  String? writerDeath;
  String? bookSlug;
  Book copyWith({
    num? id,
    String? bookName,
    String? writerName,
    dynamic aboutWriter,
    String? writerDeath,
    String? bookSlug,
  }) =>
      Book(
        id: id ?? this.id,
        bookName: bookName ?? this.bookName,
        writerName: writerName ?? this.writerName,
        aboutWriter: aboutWriter ?? this.aboutWriter,
        writerDeath: writerDeath ?? this.writerDeath,
        bookSlug: bookSlug ?? this.bookSlug,
      );
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['bookName'] = bookName;
    map['writerName'] = writerName;
    map['aboutWriter'] = aboutWriter;
    map['writerDeath'] = writerDeath;
    map['bookSlug'] = bookSlug;
    return map;
  }
}
