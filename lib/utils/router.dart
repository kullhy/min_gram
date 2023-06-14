import 'package:flutter/material.dart';
import 'package:min_gram/Screens/chat_screens.dart';
import 'package:min_gram/Screens/home_screens.dart';
import 'package:min_gram/Screens/login_with_qr.dart';

import '../Screens/chat_widget.dart';
import '../Screens/login_screens.dart';
import '../login/code_entry.dart';
import './const.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case otpRoute:
        return MaterialPageRoute(
          builder: (_) => const CodeEntryScreen(),
        );
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case qrRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreens(),
        );
      // case chatRoute:
      // return MaterialPageRoute(
      //   builder: (_) => const HomeScreens(),
      // );
      case initRoute:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Container(
              color: Colors.white,
            ),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
                child: Text(
              'No route defined for ${settings.name}',
            )),
          ),
        );
    }
  }
}
