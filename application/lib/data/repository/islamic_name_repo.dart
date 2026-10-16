import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nazar_e_alam/util/app_constants.dart';
import '../model/response/islamic_name_model.dart';

class IslamicNameRepo {
  Future<List<IslamicName>> generateNames({
    required String gender,
    required String origin,
    String? meaningTheme,
    String? startsWithLetter,
    int count = 15,
    required dynamic islamicNameApiKey,
  }) async {
    final prompt = _buildPrompt(
      gender: gender,
      origin: origin,
      meaningTheme: meaningTheme,
      startsWithLetter: startsWithLetter,
      count: count,
    );

    final response = await http.post(
      Uri.parse(AppConstants.GROK_END_POINT),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $islamicNameApiKey',
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "temperature": 0.7,
        "max_tokens": 2048,
        "messages": [
          {
            "role": "system",
            "content":
                "You are an expert Islamic scholar. Always respond with a valid JSON array only. No explanations, no markdown, no extra text.",
          },
          {"role": "user", "content": prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      debugPrint("Error: $err");
      throw Exception(
        err['error']?['message'] ?? 'API error ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    debugPrint("RAW RESPONSE: ${response.body}");

    final String rawText = _parseContent(data);
    if (rawText.isNotEmpty) {
      final clean = rawText.replaceAll(RegExp(r"```json|```"), "").trim();
      final List<dynamic> jsonList = jsonDecode(clean) as List<dynamic>;
      return jsonList
          .map((e) => IslamicName.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    debugPrint("Empty text. Full data: $data");
    return [];
  }

  static String _buildPrompt({
    required String gender,
    required String origin,
    String? meaningTheme,
    String? startsWithLetter,
    required int count,
  }) {
    final filters = <String>[];
    if (gender != 'any') filters.add('Gender: $gender names only');
    if (origin != 'any') filters.add('Origin: $origin');
    if (meaningTheme != null && meaningTheme.isNotEmpty) {
      filters.add('Meaning must relate to: "$meaningTheme"');
    }
    if (startsWithLetter != null && startsWithLetter.isNotEmpty) {
      filters.add(
        'English transliteration must start with: "${startsWithLetter.toUpperCase()}"',
      );
    }

    final filterText = filters.isEmpty
        ? 'Provide a beautiful and diverse variety of names.'
        : filters.join('\n');

    return '''
Generate exactly $count Islamic baby names as a valid JSON array only.

$filterText

Each object must have these exact fields:
- arabic (string)
- english (string)
- meaning (string)
- origin (string)
- gender (string: "boy" or "girl")
- quranicReference (string or null)

Return only the JSON array, nothing else.
''';
  }

  static String _parseContent(Map<String, dynamic> data) {
    try {
      final choices = data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final text = message?['content'] as String?;
        if (text != null && text.isNotEmpty) {
          return text.replaceAll(RegExp(r"```json|```"), "").trim();
        }
      }
    } catch (e) {
      debugPrint("Error parsing response: $e");
    }
    return '';
  }
}
