import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' as td hide Tex;

import '../services/telegram_service.dart';

//Lấy lịch sử chat
Future<List<td.Message>> getChatHistory(
    BuildContext context, int chatId) async {
  final telegramService = Provider.of<TelegramService>(context, listen: false);

  final getChatHistory = td.GetChatHistory(
    chatId: chatId,
    fromMessageId: 0,
    offset: 0,
    limit: 100,
    onlyLocal: false,
  );

  final result = await telegramService.send(getChatHistory);
  if (result is td.Messages) {
    return result.messages;
  } else {
    return [];
  }
}

class ChatScreens extends StatefulWidget {
  const ChatScreens({Key? key, required this.chatId}) : super(key: key);

  final chatId;

  @override
  State<ChatScreens> createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatScreens> {
  String message = '';
  StreamController<List<td.Message>> _messageStreamController =
      StreamController<List<td.Message>>(); // StreamController

  @override
  void initState() {
    super.initState();
    startChatHistoryUpdates();
  }

  @override
  void dispose() {
    _messageStreamController
        .close(); // Đóng StreamController khi không sử dụng nữa
    super.dispose();
  }

  void startChatHistoryUpdates() async {
    while (true) {
      //Tạo vòng lặp vô hạn để cập nhật liên tục
      final messages = await getChatHistory(context, widget.chatId);
      _messageStreamController
          .add(messages); // Gửi dữ liệu tin nhắn mới đến luồng (stream)
      await Future.delayed(
          const Duration(seconds: 1)); // Đợi 1 giây trước khi cập nhật tiếp
    }
  }

  //Gửi tin nhắn tới chatId được truyền từ HomePage
  void sendMessage(BuildContext context, String message, int chatId) async {
    final telegramService =
        Provider.of<TelegramService>(context, listen: false);

    final createPrivateChatResult =
        td.CreatePrivateChat(userId: chatId, force: false);
    final createChat = await telegramService.send(createPrivateChatResult);
    print("create new chat ${jsonEncode(createChat)}");
    if (10507 != null) {
      final sendMessage = td.SendMessage(
        chatId: chatId,
        messageThreadId: 0,
        replyToMessageId: 0,
        options: null,
        replyMarkup: null,
        inputMessageContent: td.InputMessageText(
          text: td.FormattedText(
            entities: [],
            text: message,
          ),
          clearDraft: false,
          disableWebPagePreview: false,
        ),
      );
      await telegramService.send(sendMessage);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message sent successfully'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User not found'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<td.Message>>(
              stream: _messageStreamController
                  .stream, // Sử dụng stream từ StreamController
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  var messages = snapshot.data ?? [];
                  messages = messages.reversed.toList();
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                  return ListView(
                    controller: _scrollController,
                    children: messages.map((messageValue) {
                      String messageTxt = '';
                      bool isOutgoing = messageValue.isOutgoing;
                      if (messageValue.content is td.MessageText) {
                        td.MessageText messageText =
                            messageValue.content as td.MessageText;
                        td.FormattedText text = messageText.text;
                        messageTxt = text.text;
                      }
                      final alignment = isOutgoing
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                      return Row(
                        mainAxisAlignment: isOutgoing
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: alignment,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isOutgoing ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(messageTxt ?? ''),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    message = textEditingController.text;
                    sendMessage(context, message, widget.chatId);
                    textEditingController.clear();
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
