import 'package:easy_localization/easy_localization.dart';
import 'package:expense_management/routes.dart';
import 'package:expense_management/view/intro/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'app_providers.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}


void _setupFirebaseMessaging() {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Lấy token FCM
  messaging.getToken().then((token) {
    print('FCM Token: $token');
  });

  // Xử lý khi ứng dụng đang mở
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground!');
    if (message.notification != null) {
      print('Message notification: ${message.notification}');
    }
  });

  // Xử lý khi ứng dụng đã bị đóng hoàn toàn và được mở từ thông báo
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message opened from terminated state!');
    if (message.notification != null) {
      print('Message notification: ${message.notification}');
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Ngăn ứng dụng xoay màn hình
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase connected successfully!');
  } on FirebaseException catch (e) {
    print('Firebase connection error: $e');
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );

  // Đăng ký background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  _setupFirebaseMessaging();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
        child: MaterialApp(
      title: 'Quản lý chi tiêu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routes: routes,
      home: const SplashScreen(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    ));
  }
}
