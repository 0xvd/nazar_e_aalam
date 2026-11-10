// import 'dart:convert';
// import 'dart:developer';
// import 'package:http/http.dart' as http;
// import 'package:nazar_e_alam/util/app_constants.dart';

// class AiAssistantRepo {
//   Future<String> askAI({
//     required String question,
//     required dynamic apiKey,
//   }) async {
//     final response = await http.post(
//       Uri.parse(AppConstants.GROK_END_POINT),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer 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',
//       },
//       body: jsonEncode({
//         "model": "qwen/qwen3.8-27b",
//         "messages": [
//           {
//             "role": "system",
//             "content": "You are a knowledgeable Islamic scholar. Give authentic Islamic answers. Keep answers concise and clear."
//           },
//           {
//             "role": "user",
//             "content": question
//           }
//         ],
//       }),
//     );

//     log('Response headers: ${response.headers}');
//     log('Response body: ${response.body}');

//     if (response.statusCode != 200) {
//       log('Response headers: ${response.headers}');
//       log('Response body: ${response.body}');
//       throw Exception("API Error: ${response.statusCode}: ${response.body}");
//     }

//     final data = jsonDecode(response.body);

//     return data['choices'][0]['message']['content'];
//   }
// }