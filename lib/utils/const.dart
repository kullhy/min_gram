import 'package:flutter/material.dart' show GlobalKey, NavigatorState;

const String initRoute = '/splash';
const String loginRoute = '/login';
const String otpRoute = '/code_entry';
const String qrRoute = '/qr_entry';
const String homeRoute = '/addtochat';
const String chatRoute = '/chatsceens';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }
}
