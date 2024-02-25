import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/login_page.dart';
import 'package:get_it/get_it.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  final getIt = GetIt.instance;

  // Allow network requests to localhost over HTTP
  HttpOverrides.global = MyHttpOverrides();

  // Register services
  await getIt.registerSingleton(AuthenticationService(baseUrl: 'https://10.0.2.2:7074/api', secureStorage: FlutterSecureStorage()));

  // Register views
  getIt.registerFactory<LoginPage>(() => LoginPage());
  // getIt.registerFactory<HomePage>(() => HomePage());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musewave',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const HomePage(title: 'Musewave'),
      home: LoginPage(),
    );
  }
}
