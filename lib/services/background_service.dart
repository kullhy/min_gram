// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';

// class BackgroundService {
//   static Future<void> start() async {
//     WidgetsFlutterBinding.ensureInitialized();

//     // Bắt đầu dịch vụ background
//     FlutterBackgroundService.initialize(onStart);

//     // Thông báo rằng dịch vụ đã được bắt đầu
//     FlutterBackgroundService().sendData(
//       {'action': 'start', 'text': 'Background service started'},
//     );

//     // Chờ cho đến khi dịch vụ bị dừng
//     await FlutterBackgroundService().done;
//   }

//   static Future<void> onStart() async {
//     // Gọi hàm getContacts ở đây
//     final telegramService = Provider.of<TelegramService>(context, listen: false);
//     final result = await telegramService.send(searchQuery);

//     // Xử lý kết quả và gửi thông báo
//     // ...

//     // Kết thúc dịch vụ
//     FlutterBackgroundService().stop();
//   }
// }
