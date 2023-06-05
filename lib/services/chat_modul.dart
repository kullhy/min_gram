// import 'package:tdlib/td_api.dart' as td;
// import 'package:tdlib/tdlib.dart';
// import 'package:tdlib/td_api.dart';

// class MessageModule {
//   td.TdClient? client;

//   Future<void> initialize() async {
//     client = td.TdClient();
//     await client!.connect();
//   }

//   Future<void> close() async {
//     await client?.close();
//     client = null;
//   }

//   Future<int> getUserIdByPhoneNumber(String phoneNumber) async {
//     final query = td.SearchContacts(
//       query: phoneNumber,
//       limit: 1,
//     );

//     final result = await client!.execute(query);

//     if (result is td.Users) {
//       final users = result as td.Users;
//       if (users.userIds.isNotEmpty) {
//         return users.userIds.first;
//       }
//     }

//     throw Exception('Không tìm thấy người dùng với số điện thoại đã cho');
//   }

//   Future<void> sendMessage(int userId, String messageText) async {
//     final sendMessage = td.SendMessage(
//       chatId: userId,
//       inputMessageContent: td.InputMessageText(
//         text: td.FormattedText(
//           text: messageText,
//         ),
//       ),
//     );

//     await client!.send(sendMessage);
//   }
// }
