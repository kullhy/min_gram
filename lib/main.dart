import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:min_gram/services/noti_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tdlib/td_client.dart';

import 'utils/router.dart' as utilrouter;
import 'services/locator.dart';
import 'services/telegram_service.dart';
import 'utils/const.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
BuildContext? appContext = navigatorKey.currentContext;
BuildContext? mainContext;
void main() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then(
    (value) {
      Permission.notification.request();
    },
  );
  await initializeService();
  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlay.);
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await TdPlugin.initialize();
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        Provider<TelegramService>(
          create: (_) => TelegramService(lastRouteName: initRoute),
          lazy: false,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return MaterialApp(
      navigatorKey: locator<NavigationService>().navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      onGenerateRoute: utilrouter.Router.generateRoute,
      initialRoute: initRoute,
    );
  }
}
