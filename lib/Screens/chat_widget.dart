import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' hide Text;

import '../services/telegram_service.dart';

class SendMessageScreen extends StatefulWidget {
  final String phoneNumber;

  SendMessageScreen({required this.phoneNumber});

  @override
  _SendMessageScreenState createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  String message = '';
  List<Message> Hmessages = [];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'To: ${widget.phoneNumber}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  message = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Message',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                sendMessage(context);
              },
              child: Text('Send'),
            ),
            ElevatedButton(
              onPressed: () async {
                Hmessages = await getChatHistory(context);
                print("test history ${jsonEncode(Hmessages)}");
              },
              child: Text('history chat'),
            ),
            //  Expanded(
            //     child: ListView.builder(
            //       itemCount: Hmessages.length,
            //       itemBuilder: (context, index) {
            //         final message = Hmessages[index];

            //         // Tạo các Widget cho từng tin nhắn
            //         return ListTile(
            //           title: Text(message.senderId.toString()),
            //           subtitle: Text(message.content.toString()),
            //         );
            //       },
            //     ),
            //   )
          ],
        ),
      ),
    );
  }

  Future<List<Message>> getChatHistory(BuildContext context) async {
    final telegramService =
        Provider.of<TelegramService>(context, listen: false);

    // final userId =
    //     await telegramService.searchUserByPhoneNumber(widget.phoneNumber);
    // print("user ID : $userId");

    final getChatHistory = GetChatHistory(
      chatId: 6252774475,
      fromMessageId: 0,
      offset: 0,
      limit: 10,
      onlyLocal: false,
    );

    final result = await telegramService.send(getChatHistory);
    if (result is Messages) {
      return result.messages;
    } else {
      return [];
    }
  }

  void sendMessage(BuildContext context) async {
    final telegramService =
        Provider.of<TelegramService>(context, listen: false);

    // final userId =
    //     await telegramService.searchUserByPhoneNumber(widget.phoneNumber);
    // print("user ID : $userId");
    if (10507 != null) {
      final sendMessage = SendMessage(
        chatId: 6252774475,
        messageThreadId: 0,
        replyToMessageId: 0,
        options: null,
        replyMarkup: null,
        inputMessageContent: InputMessageText(
          text: FormattedText(
            entities: [],
            text: message,
          ),
          clearDraft: false,
          disableWebPagePreview: false,
        ),
      );
      await telegramService.send(sendMessage);
      print("object ${jsonEncode(telegramService.send(sendMessage))}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message sent successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User not found'),
      ));
    }
  }
}
