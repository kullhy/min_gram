// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tdlib/td_api.dart' hide Text;

// import '../services/telegram_service.dart';

// // Lấy danh sách tin nhắn từ chatId
// Future<List<Message>> getChatMessages(int chatId) async {

//   final telegramService =
//     Provider.of<TelegramService>(context, listen: false);
//   final getHistory = GetChatHistory(
//     chatId: chatId,
//     limit: 20, // Số lượng tin nhắn cần lấy
//   );

//   final result = await telegramService.send(getHistory);
//   if (result is Messages) {
//     return result.messages;
//   }

//   return [];
// }

// // Widget hiển thị danh sách tin nhắn
// class ChatScreen extends StatefulWidget {
//   final int chatId;

//   ChatScreen({required this.chatId});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   List<Message> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchChatMessages();
//   }

//   void fetchChatMessages() async {
//     final chatMessages = await getChatMessages(widget.chatId);
//     setState(() {
//       messages = chatMessages;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat Screen'),
//       ),
//       body: ListView.builder(
//         itemCount: messages.length,
//         itemBuilder: (context, index) {
//           final message = messages[index];

//           // Tạo các Widget cho từng tin nhắn
//           return ListTile(
//             title: Text(message.senderUserId.toString()),
//             subtitle: Text(message.content.text.text),
//           );
//         },
//       ),
//     );
//   }
// }
