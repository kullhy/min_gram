import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tdlib/tdlib.dart';
import 'package:tdlib/td_api.dart';

import './locator.dart';
import '../utils/const.dart';

int _random() => Random().nextInt(10000000);
late AuthorizationState tdState;

class TelegramService extends ChangeNotifier {
  late int _client;
  late StreamController<TdObject> _eventController;
  late StreamSubscription<TdObject> _eventReceiver;
  StreamController<Update> _updateController =
      StreamController<Update>.broadcast();
  Stream<Update> get updateStream => _updateController.stream;
  Map results = <int, Completer>{};
  Map callbackResults = <int, Future<void>>{};
  late Directory appDocDir;
  late Directory appExtDir;
  String lastRouteName;

  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  bool _isClientInitialized = false;

  TelegramService({this.lastRouteName = initRoute}) {
    _eventController = StreamController();
    _eventController.stream.listen(_onEvent);
    initClient();
  }

  void initClient() async {
    _client = tdCreate();
    _isClientInitialized = true;

    // ignore: unused_local_variable
    bool storagePermission = await Permission.storage
        .request()
        .isGranted; // todo : handel storage permission

    appDocDir = await getApplicationDocumentsDirectory();
    appExtDir = await getTemporaryDirectory();

    //execute(SetLogStream(logStream: LogStreamEmpty()));
    execute(const SetLogVerbosityLevel(newVerbosityLevel: 1));
    tdSend(_client, const GetCurrentState());
    _isolate = await Isolate.spawn(_receive, _receivePort.sendPort,
        debugName: "isolated receive");
    _receivePort.listen(_receiver);
  }

  static _receive(sendPortToMain) async {
    TdNativePlugin.registerWith();
    await TdPlugin.initialize();
    //var x = _rawClient.td_json_client_create();
    while (true) {
      final s = TdPlugin.instance.tdReceive();
      if (s != null) {
        sendPortToMain.send(s);
      }
    }
  }

  void _receiver(dynamic newEvent) async {
    final event = convertToObject(newEvent);
    if (event == null) {
      return;
    }
    if (event is Updates) {
      for (var event in event.updates) {
        _eventController.add(event);
      }
    } else {
      _eventController.add(event);
    }
    await _resolveEvent(event);
  }

  Future _resolveEvent(event) async {
    if (event.extra == null) {
      return;
    }
    final int extraId = event.extra;
    if (results.containsKey(extraId)) {
      results.remove(extraId).complete(event);
    } else if (callbackResults.containsKey(extraId)) {
      await callbackResults.remove(extraId);
    }
  }

  void stop() {
    _eventController.close();
    _eventReceiver.cancel();
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  void _onEvent(TdObject event) async {
    switch (event.getConstructor()) {
      case UpdateAuthorizationState.CONSTRUCTOR:
        tdState = (event as UpdateAuthorizationState).authorizationState;
        await _authorizationController(
          (event as UpdateAuthorizationState).authorizationState,
          isOffline: true,
        );
        break;
      default:
        return;
    }
  }

  Future _authorizationController(
    AuthorizationState authState, {
    bool isOffline = false,
  }) async {
    String route;
    print("Trạng thái đầu $tdState");
    switch (authState.getConstructor()) {
      case AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        await send(
          SetTdlibParameters(
            parameters: TdlibParameters(
              useTestDc: false,
              useSecretChats: false,
              useMessageDatabase: true,
              useFileDatabase: true,
              useChatInfoDatabase: true,
              ignoreFileNames: true,
              enableStorageOptimizer: true,
              systemLanguageCode: 'EN',
              filesDirectory: appExtDir.path + '/tdlib',
              databaseDirectory: appDocDir.path,
              applicationVersion: '0.0.1',
              deviceModel: 'Unknown',
              systemVersion: 'Unknonw',
              apiId: 23494474,
              apiHash: '1f97f0fa1bf0c53f1df648b9c7021d8f',
            ),
          ),
        );
        return;
      case AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
        if ((authState as AuthorizationStateWaitEncryptionKey).isEncrypted) {
          await send(
            const CheckDatabaseEncryptionKey(
              encryptionKey: 'mostrandomencryption',
            ),
          );
        } else {
          await send(
            const SetDatabaseEncryptionKey(
              newEncryptionKey: 'mostrandomencryption',
            ),
          );
        }
        return;
      case AuthorizationStateWaitPhoneNumber.CONSTRUCTOR:
      case AuthorizationStateClosed.CONSTRUCTOR:
        route = loginRoute;
        break;
      case AuthorizationStateReady.CONSTRUCTOR:
        route = homeRoute;
        break;
      case AuthorizationStateWaitCode.CONSTRUCTOR:
        route = otpRoute;
        break;
      case AuthorizationStateWaitOtherDeviceConfirmation.CONSTRUCTOR:
        route = qrRoute;
        break;
      case AuthorizationStateWaitRegistration.CONSTRUCTOR:
      case AuthorizationStateWaitPassword.CONSTRUCTOR:
      case AuthorizationStateLoggingOut.CONSTRUCTOR:
      case AuthorizationStateClosing.CONSTRUCTOR:
        return;
      default:
        return;
    }

    if (route == lastRouteName) return;
    lastRouteName = route;
    locator<NavigationService>().navigateTo(route);
  }

  void destroyClient() async {
    tdSend(_client, const Close());
  }

  /// Sends request to the TDLib client. May be called from any thread.
  Future<TdObject?> send(event, {Future<void>? callback}) async {
    // ignore: missing_return
    final rndId = _random();
    if (callback != null) {
      callbackResults[rndId] = callback;
      try {
        tdSend(_client, event, rndId);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      final completer = Completer<TdObject>();
      results[rndId] = completer;
      tdSend(_client, event, rndId);
      return completer.future;
    }
  }

  /// Synchronously executes TDLib request. May be called from any thread.
  /// Only a few requests can be executed synchronously.
  /// Returned pointer will be deallocated by TDLib during next call to clientReceive or clientExecute in the same thread, so it can't be used after that.
  TdObject execute(TdFunction event) => tdExecute(event)!;

  Future setAuthenticationPhoneNumber(
    String phoneNumber, {
    required void Function(TdError) onError,
  }) async {
    final result = await send(
      SetAuthenticationPhoneNumber(
        phoneNumber: phoneNumber,
        settings: const PhoneNumberAuthenticationSettings(
          allowFlashCall: false,
          isCurrentPhoneNumber: false,
          allowSmsRetrieverApi: false,
          allowMissedCall: true,
          authenticationTokens: [],
        ),
      ),
    );
    if (result != null && result is TdError) {
      onError(result);
    }
  }

  Future<List<int>> getContacts() async {
    if (!_isClientInitialized) {
      initClient();
    }
    print("call on service");
    final result = await send(GetContacts());
    final completer = Completer<List<int>>();
    if (result != null && result is Users) {
      completer.complete(result.userIds);
    } else {
      print("Không lấy được danh sách liên hệ");
      completer.complete([]);
    }
    return completer.future;
  }

//   void startListeningMessages(int userId) {
//   _messageController = StreamController<Message>();
//   _eventController.stream.listen((event) {
//     if (event is Message) {
//       _messageController.add(event);
//     }
//   });
// }
  bool isClientInitialized() {
    return _isClientInitialized;
  }

  Future requestQR({
    required void Function(TdError) onError,
  }) async {
    AuthorizationState authState = AuthorizationState();
    print("Trạng thái rqqr $authState");

    await send(
        RequestQrCodeAuthentication(otherUserIds: []));
  }

  Future checkAuthenticationCode(
    String code, {
    required void Function(TdError) onError,
  }) async {
    final result = await send(
      CheckAuthenticationCode(
        code: code,
      ),
    );
    if (result != null && result is TdError) {
      onError(result);
    }
  }
}
