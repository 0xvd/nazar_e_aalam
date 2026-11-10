// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:nazar_e_alam/controller/ai_assistant_controller.dart';
// import 'package:nazar_e_alam/theme/light_theme.dart';

// import '../../../util/styles.dart';
// import '../../base/custom_app_bar.dart';

// class AiIslamicAssistantScreen extends StatelessWidget {
//   const AiIslamicAssistantScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<AiAssistantController>(
//       builder: (ctrl) {
//         final scrollCtrl = ScrollController();
//         return Scaffold(
//           // backgroundColor: const Color(0xFFFAF6EE),
//           appBar: CustomAppBar(
//             isBackButtonExist: true,
//             title: 'ai_islamic_assistant'.tr,
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.delete_outline),
//                 onPressed: () => ctrl.clearChat(),
//               ),
//             ],
//           ),
//           body: Column(
//             children: [
//               /// Chat List
//               Expanded(
//                 child: Obx(
//                   () => ListView.builder(
//                     controller: scrollCtrl,
//                     padding: const EdgeInsets.all(12),
//                     itemCount: ctrl.messages.length,
//                     itemBuilder: (_, i) {
//                       final msg = ctrl.messages[i];
//                       return _buildMessageBubble(context, msg);
//                     },
//                   ),
//                 ),
//               ),

//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: _buildInputBar(context, ctrl),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// Message Bubble
//   Widget _buildMessageBubble(BuildContext context, ChatMessage msg) {
//     final isUser = msg.isUser;

//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Bot avatar
//           if (!isUser) ...[
//             Container(
//               width: 30,
//               height: 30,
//               margin: const EdgeInsets.only(right: 8, top: 2),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2D5E4A),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: const Color(0xFFE8D4A0), width: 1.5),
//               ),
//               child: const Icon(
//                 Icons.auto_awesome,
//                 color: Color(0xFFE8D4A0),
//                 size: 13,
//               ),
//             ),
//           ],

//           // Bubble
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             padding: const EdgeInsets.all(12),
//             constraints: BoxConstraints(maxWidth: Get.width * .72),
//             decoration: BoxDecoration(
//               color: isUser
//                   ? const Color(0xFF2D5E4A)
//                   : Theme.of(context).primaryColor,
//               borderRadius: BorderRadius.only(
//                 topLeft: const Radius.circular(18),
//                 topRight: const Radius.circular(18),
//                 bottomLeft: Radius.circular(isUser ? 18 : 4),
//                 bottomRight: Radius.circular(isUser ? 4 : 18),
//               ),
//               border: isUser
//                   ? null
//                   : Border.all(
//                       color: const Color(0xFFC9A84C).withValues(alpha: 0.25),
//                     ),
//               boxShadow: isUser
//                   ? null
//                   : [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.06),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//             ),
//             child: Text(
//               msg.text,
//               style: robotoRegular.copyWith(
//                 color: AppColor.cardColor,
//                 height: 1.55,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Input Bar
//   Widget _buildInputBar(BuildContext context, AiAssistantController ctrl) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
//       decoration: const BoxDecoration(
//         border: Border(top: BorderSide(color: Color(0x40C9A84C), width: 1)),
//       ),
//       child: Row(
//         children: [
//           // Text Field
//           Expanded(
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(25),
//                 border: Border.all(
//                   color: const Color(0xFFC9A84C).withValues(alpha: 0.3),
//                   width: 1.5,
//                 ),
//               ),
//               child: TextField(
//                 controller: ctrl.questionCtrl,
//                 style: robotoRegular.copyWith(
//                   fontSize: 14,
//                   color: Color(0xFF3D3520),
//                 ),
//                 decoration: InputDecoration(
//                   hintText: "ask_islamic_question".tr,
//                   hintStyle: robotoRegular.copyWith(),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // Send Button
//           Obx(
//             () => GestureDetector(
//               onTap: ctrl.isLoading.value ? null : ctrl.askQuestion,
//               child: Container(
//                 width: 46,
//                 height: 46,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF2D5E4A),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF2D5E4A).withValues(alpha: 0.35),
//                       blurRadius: 14,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ctrl.isLoading.value
//                     ? const Padding(
//                         padding: EdgeInsets.all(13),
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Icon(
//                         Icons.send_rounded,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;

//   ChatMessage({required this.text, required this.isUser});

//   Map<String, dynamic> toJson() => {"text": text, "isUser": isUser};

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(text: json["text"], isUser: json["isUser"]);
//   }
// }
