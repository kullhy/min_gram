import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:min_gram/Screens/chat_screens.dart';
import 'package:min_gram/Screens/home_screens.dart';
import 'package:min_gram/database/savetodb.dart';
import 'package:min_gram/main.dart';
import 'package:min_gram/services/telegram_service.dart';
import 'package:tdlib/src/tdapi/tdapi.dart';

import '../database/table.dart';

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;
const notificationId2 = 999;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        autoStartOnBoot: true,

        notificationChannelId:
            notificationChannelId, // this must match with notification channel you created above.
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: notificationId,
      ));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  bool is_noti = true;
  String? text = "";
  String? userName = "";
  String userId = "";
  print("onstart ok");
  // DartPluginRegistrant.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    print("set back");
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  int x = 0;
  Timer.periodic(Duration(seconds: 1), (timer) async {
    print("test timer ");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        print("test fore ");
        final contacts = await getContacts();

        // saveUserToDatabase(contacts.cast<Contact>());
        for (int i = 0; i < contacts.length; i++) {
          final lastMessages =
              await getChatHistory(mainContext as BuildContext, contacts[i]);
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
            if (message != null) {
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
                  final messageId =
                      await database.insert('message', messageRow);
                  print('Message with ID $messageId saved successfully.');
                  text = messageTxt;
                });
              } catch (e) {
                print('Failed to save message: $e');
              }
            }
          }
        }
        print("ok noti");
      }
      if (is_noti) {
        flutterLocalNotificationsPlugin.show(
          notificationId2,
          '$userName',
          '$text',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: false,
            ),
          ),
          payload: userId,
        );
        is_noti = false;
      }
    }
    print("background service running $is_noti");

    print("background service running");
    service.invoke('update');
  });
}

Future<List<int>> getContacts() async {
  print("test contact }");
  final telegramService = TelegramService();
  const searchQuery = GetContacts();
  final result = await telegramService.send(searchQuery);
  if (result is Users) {
    final user = result.userIds;
    return user;
  } else {
    print("Khong lay duoc contact");
    return [];
  }
}
