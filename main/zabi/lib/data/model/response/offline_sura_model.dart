class OfflineSurahListModel {
  final int id;
  final String serialNumber;
  final String arabicName;
  final int startPage;
  final int endPage;
  final String translateName;
  final String versesTranslateName;
  final String versesCount;

  OfflineSurahListModel({
    required this.id,
    required this.serialNumber,
    required this.arabicName,
    required this.startPage,
    required this.endPage,
    required this.translateName,
    required this.versesTranslateName,
    required this.versesCount,
  });

  factory OfflineSurahListModel.fromJson(Map<String, dynamic> json) {
    return OfflineSurahListModel(
      id: json['id'] ?? 0,
      serialNumber: json['serial_number'] ?? '',
      arabicName: json['arabic_name'] ?? '',
      startPage: json['start_page'] ?? 0,
      endPage: json['end_page'] ?? 0,
      translateName: json['translate_name'] ?? '',
      versesTranslateName: json['verses_translate_name'] ?? '',
      versesCount: json['verses_count'] ?? '',
    );
  }
}
