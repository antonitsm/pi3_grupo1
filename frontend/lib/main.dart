import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:frontend/paginas/splash_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

Future<void> configurarNotificacoes() async {
  // Não configura notificações na Web
  if (kIsWeb) {
    return;
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  // Inscreve no tópico apenas em Android e iOS
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await messaging.subscribeToTopic("projects");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Título: ${message.notification?.title}");
    print("Corpo: ${message.notification?.body}");
  });
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Mensagem em background: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
