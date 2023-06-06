import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import '../model/user/result.dart';
import '../screens/detail_screens.dart';
import '../sqlite/data.dart';
import 'getUpdates.dart';

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
  bool is_noti = false;
  String? text = "";
  String? userName = "";
  String userId = "";

  DartPluginRegistrant.ensureInitialized();
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
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        print("ok noti");
        final results = await ApiService.fetchResults();
        final database = await DatabaseHelper.instance.database;
        for (int i = 0; i < results.length; i++) {
          final message = results[i].message;
          if (message != null) {
            final messageRow = {
              'id': message.messageId,
              'user_id': message.from?.id,
              'text': message.text,
              'date_time': message.date,
              'is_sent': 1,
            };

            try {
              // Chuyển phần thao tác cập nhật vào một luồng khác
              await Future.delayed(Duration.zero, () async {
                final messageId = await database.insert('message', messageRow);
                print('Message with ID ${message.text} aved successfully.');
                // service.setForegroundNotificationInfo(title: "1", content: "2");
                // sendNotificationFromLastData();
                is_noti = true;
                text = message.text;
                userName =
                    " ${message.from?.firstName} ${message.from?.lastName ?? ""}";
                userId = "${message.from?.id}";
              });
            } catch (e) {
              print('Failed to save message: $e');
            }
          }
        }
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
