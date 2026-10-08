class LocalDhikrModel {
  final String id;
  final String englishName;
  final String arabicName;
  final String englishDescription;
  final String arabicDescription;

  LocalDhikrModel({
    required this.id,
    required this.englishName,
    required this.arabicName,
    required this.englishDescription,
    required this.arabicDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'englishName': englishName,
      'arabicName': arabicName,
      'englishDescription': englishDescription,
      'arabicDescription': arabicDescription,
    };
  }

  factory LocalDhikrModel.fromJson(Map<String, dynamic> json) {
    return LocalDhikrModel(
      id: json['id'],
      englishName: json['englishName'],
      arabicName: json['arabicName'],
      englishDescription: json['englishDescription'],
      arabicDescription: json['arabicDescription'],
    );
  }
}
