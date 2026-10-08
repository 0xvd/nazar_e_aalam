class HadisBookModel {
  num? status;
  String? message;
  List<Books>? books;

  HadisBookModel({this.status, this.message, this.books});

  HadisBookModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] is num
        ? json['status']
        : num.tryParse(json['status'].toString());

    message = json['message']?.toString();

    if (json['books'] != null) {
      books = (json['books'] as List)
          .map((e) => Books.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'books': books?.map((e) => e.toJson()).toList(),
    };
  }

  HadisBookModel copyWith({num? status, String? message, List<Books>? books}) {
    return HadisBookModel(
      status: status ?? this.status,
      message: message ?? this.message,
      books: books ?? this.books,
    );
  }
}

class Books {
  num? id;
  String? bookName;
  String? writerName;
  String? aboutWriter;
  String? writerDeath;
  String? bookSlug;
  String? hadithsCount;
  String? chaptersCount;

  Books({
    this.id,
    this.bookName,
    this.writerName,
    this.aboutWriter,
    this.writerDeath,
    this.bookSlug,
    this.hadithsCount,
    this.chaptersCount,
  });

  Books.fromJson(Map<String, dynamic> json) {
    id = json['id'] is num ? json['id'] : num.tryParse(json['id'].toString());

    bookName = json['bookName']?.toString();
    writerName = json['writerName']?.toString();
    aboutWriter = json['aboutWriter']?.toString();
    writerDeath = json['writerDeath']?.toString();
    bookSlug = json['bookSlug']?.toString();
    hadithsCount = json['hadiths_count']?.toString();
    chaptersCount = json['chapters_count']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookName': bookName,
      'writerName': writerName,
      'aboutWriter': aboutWriter,
      'writerDeath': writerDeath,
      'bookSlug': bookSlug,
      'hadiths_count': hadithsCount,
      'chapters_count': chaptersCount,
    };
  }

  Books copyWith({
    num? id,
    String? bookName,
    String? writerName,
    String? aboutWriter,
    String? writerDeath,
    String? bookSlug,
    String? hadithsCount,
    String? chaptersCount,
  }) {
    return Books(
      id: id ?? this.id,
      bookName: bookName ?? this.bookName,
      writerName: writerName ?? this.writerName,
      aboutWriter: aboutWriter ?? this.aboutWriter,
      writerDeath: writerDeath ?? this.writerDeath,
      bookSlug: bookSlug ?? this.bookSlug,
      hadithsCount: hadithsCount ?? this.hadithsCount,
      chaptersCount: chaptersCount ?? this.chaptersCount,
    );
  }
}
