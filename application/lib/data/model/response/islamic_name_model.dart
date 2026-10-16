class IslamicName {
  final String arabic;
  final String english;
  final String meaning;
  final String origin;
  final String gender;
  final String? quranicReference;
  bool isFavorite;

  IslamicName({
    required this.arabic,
    required this.english,
    required this.meaning,
    required this.origin,
    required this.gender,
    this.quranicReference,
    this.isFavorite = false,
  });

  factory IslamicName.fromJson(Map<String, dynamic> json) {
    return IslamicName(
      arabic: json['arabic'] ?? '',
      english: json['english'] ?? '',
      meaning: json['meaning'] ?? '',
      origin: json['origin'] ?? 'Arabic',
      gender: json['gender'] ?? 'any',
      quranicReference: json['quranicReference'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'arabic': arabic,
    'english': english,
    'meaning': meaning,
    'origin': origin,
    'gender': gender,
    'quranicReference': quranicReference,
    'isFavorite': isFavorite,
  };
}