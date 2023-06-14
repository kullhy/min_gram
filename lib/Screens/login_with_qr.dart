import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_api.dart' as td hide Text;
// import 'package:tdlib/td_api.dart';
// import 'package:tdlib/td_api.dart';
import '../services/a.dart';
import '../services/telegram_service.dart';

// void logInByQr(BuildContext context) async {
//   print("login with qr 1");
//   final telegramService = Provider.of<TelegramService>(context, listen: true);
//   print("login with qr 2");
//   const requestQr =
//       td.RequestQrCodeAuthentication(otherUserIds: [6005052616, 901348084]);
//       print("login with qr 3");
//   final results = telegramService.send(requestQr);
//   print("check results ${jsonEncode(results)}");

// }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _QRError = "";
  String qrCodeLink = "";

  final TextEditingController t = TextEditingController();
  final FocusNode f = FocusNode();
  String qrLink = "https://www.postman.com/downloads/", authState = "showQR";

  void qrListener(String link) {
    authState = "showQR";
    setState(() => qrLink = 'https://www.postman.com/downloads/');
  }

  // void stateListener(String state) {
  //   if (state == "done") {
  //     Navigator.of(context).pushReplacementNamed("/home");
  //   } else {
  //     setState(() => authState = state);
  //   }
  // }

  @override
  void initState() {
    // context.read<TelegramService>().,
    context.read<TelegramService>().requestQR(onError: _handelError);
    handleAuthorizationState();
    super.initState();
  }

  void handleAuthorizationState() {
    late td.AuthorizationState authState;
    authState = tdState;
    print("trạng thái tại màn hình $tdState");
    if (authState is td.AuthorizationStateWaitOtherDeviceConfirmation) {
      qrCodeLink = authState.link;
      // Sử dụng qrCodeLink trong ứng dụng của bạn
    }
  }

  void _handelError(td.TdError error) async {
    setState(() {
      _QRError = error.message;
      print("looix $_QRError");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            "Login into Telegram",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          const Text(
            "Scan QR",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          PrettyQr(
            size: MediaQuery.of(context).size.width - 80,
            data: qrCodeLink,
            errorCorrectLevel: QrErrorCorrectLevel.L,
            elementColor:
                Theme.of(context).textTheme.bodyLarge!.color ?? Colors.white,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
