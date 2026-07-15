import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/paginas/splash_screen.dart';
import 'firebase_options.dart';

Future<void> configurarNotificacoes() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings =
      await messaging.requestPermission();

  if (settings.authorizationStatus ==
      AuthorizationStatus.authorized) {

    await messaging.subscribeToTopic("projects");

    print("Inscrito no tópico projects");

    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification?.title);
    });
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Mensagem em background: ${message.notification?.title}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configurarNotificacoes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}