import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> configurarNotificacoes() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings =
      await messaging.requestPermission();

  if (settings.authorizationStatus ==
      AuthorizationStatus.authorized) {
    print("Permissão concedida");

    String? token = await messaging.getToken();
    print("TOKEN: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Título: ${message.notification?.title}");
      print("Mensagem: ${message.notification?.body}");
    });

  } else {
    print("Permissão negada");
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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await configurarNotificacoes();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    );
  }
}