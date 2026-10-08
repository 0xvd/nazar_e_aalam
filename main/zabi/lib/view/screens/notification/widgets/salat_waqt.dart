import 'dart:convert';

class SalatWaqt {
  int id;
  String name;
  DateTime time;
  bool isNotificationEnabled;
  SalatWaqt({
    required this.id,
    required this.name,
    required this.time,
    required this.isNotificationEnabled,
  });

  factory SalatWaqt.fromMap(Map<String, dynamic> map) => SalatWaqt(
        id: map['id'] as int,
        name: map['name'] as String,
        time: DateTime.parse(map['time']),
        isNotificationEnabled: map['isNotificationEnabled'] as bool,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'time': time.toIso8601String(),
        'isNotificationEnabled': isNotificationEnabled,
      };

  factory SalatWaqt.fromJson(String json) =>
      SalatWaqt.fromMap(jsonDecode(json));

  String toJson() => jsonEncode(toMap());
}
