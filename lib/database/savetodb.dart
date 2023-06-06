import 'dart:convert';

import 'package:min_gram/database/table.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tdlib/td_api.dart';

Future<void> saveUserToDatabase(List<Contact> contacts) async {
  final database = await DatabaseHelper.instance.database;
  print("test mes ${contacts.length}");
  int x = 0;

  for (int i = 0; i < contacts.length; i++) {
    x = x + 1;
    print("test mes ${x} ${jsonEncode(contacts[i])}");
    final contact = contacts[i];
    final contactRow = {
      'id': contact.userId,
      'first_name': contact.firstName,
      'last_name': contact.lastName
    };

    try {
      // Chuyển phần thao tác cập nhật vào một luồng khác
      await Future.delayed(Duration.zero, () async {
        final contactId = await database.insert('message', contactRow);
        print('contact with ID $contactId saved successfully.');
      });
    } catch (e) {
      print('Failed to save contact: $e');
    }
  }
}

Future<void> saveLastMassage(List<Message> lastMessages) async {
  final database = await DatabaseHelper.instance.database;
  print("test mes ${lastMessages.length}");
  int x = 0;

  for (int i = 0; i < lastMessages.length; i++) {
    x = x + 1;
    print("test mes ${x} ${jsonEncode(lastMessages[i])}");
    final message = lastMessages[i];

    String messageTxt = "";
    if (message.content is MessageText) {
      MessageText messageText = message.content as MessageText;
      FormattedText text = messageText.text;
      messageTxt = text.text;
    }
    final messageRow = {
      'id': message.chatId,
      'user_id': message.id,
      'text': messageTxt,
      'date_time': message.date,
      'is_sent': 1,
    };

    try {
      // Chuyển phần thao tác cập nhật vào một luồng khác
      await Future.delayed(Duration.zero, () async {
        final messageId = await database.insert('message', messageRow);
        print('Message with ID $messageId saved successfully.');
      });
    } catch (e) {
      print('Failed to save message: $e');
    }
  }
}
