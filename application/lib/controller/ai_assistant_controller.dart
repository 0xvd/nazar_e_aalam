// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

// import '../data/repository/ai_assistant_repo.dart';
// import '../view/screens/ai_islamic_assistant/ai_islamic_assistant.dart';

// class AiAssistantController extends GetxController {
//   final AiAssistantRepo assistantRepo;
//   AiAssistantController({required this.assistantRepo});
//   final questionCtrl = TextEditingController();
//   final scrollCtrl = ScrollController();

//   var isLoading = false.obs;
//   RxList<ChatMessage> messages = <ChatMessage>[].obs;

//   static const _storageKey = "ai_islamic_chat";

//   @override
//   void onInit() {
//     super.onInit();
//     loadChat();
//   }

//   /// LOAD CHAT
//   Future<void> loadChat() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getString(_storageKey);

//     if (data != null) {
//       final List decoded = jsonDecode(data);
//       messages.value = decoded.map((e) => ChatMessage.fromJson(e)).toList();
//     } else {
//       messages.add(
//         ChatMessage(
//           text: "Assalamu Alaikum! Ask me any Islamic question.",
//           isUser: false,
//         ),
//       );
//     }
//   }

//   /// SAVE CHAT
//   Future<void> saveChat() async {
//     final prefs = await SharedPreferences.getInstance();
//     final encoded = jsonEncode(messages.map((e) => e.toJson()).toList());
//     await prefs.setString(_storageKey, encoded);
//   }

//   Future<void> askQuestion() async {
//     final question = questionCtrl.text.trim();
//     if (question.isEmpty) return;

//     messages.add(ChatMessage(text: question, isUser: true));
//     questionCtrl.clear();
//     await saveChat();
//     isLoading.value = true;

//     try {
//       final answer = await assistantRepo.askAI(
//         question: question,
//         apiKey: Get.find<SettingsController>()
//             .mosqueSettingsApiData
//             ?.data
//             ?.islamicNameApiKey,
//       );

//       messages.add(ChatMessage(text: answer, isUser: false));
//       await saveChat();
//     } catch (e) {
//       messages.add(
//         ChatMessage(
//           text: "Error: Unable to get answer. Please try again.",
//           isUser: false,
//         ),
//       );
//     }

//     isLoading.value = false;
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (scrollCtrl.hasClients) {
//         scrollCtrl.animateTo(
//           scrollCtrl.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   /// CLEAR CHAT
//   Future<void> clearChat() async {
//     messages.clear();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_storageKey);

//     messages.add(
//       ChatMessage(
//         text: "Assalamu Alaikum! Ask me any Islamic question.",
//         isUser: false,
//       ),
//     );
//   }
// }
