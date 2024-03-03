import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized before using SecureStorage

  // const baseUrl = String.fromEnvironment('BASE_URL'); // 'https://10.0.2.2:7074/api'

  final getIt = GetIt.instance;

  // Allow network requests to localhost over HTTP
  HttpOverrides.global = MyHttpOverrides();

  // Register secure storage
  final secureStorage = await getIt.registerSingleton(FlutterSecureStorage());

  // Register services
  final apiService = await getIt.registerSingleton(ApiService(secureStorage: secureStorage));
  final authService = await getIt.registerSingleton(AuthenticationService(secureStorage: secureStorage));
  final tracksService = await getIt.registerSingleton(TracksService(secureStorage));
  final albumService = await getIt.registerSingleton(AlbumService(secureStorage));

  // Get the token from secure storage
  final access_token = await authService.checkLocalStorageForToken();

  final router = routerGenerator(authService.getLoggedInState());

  runApp(MyApp(
    // initialRoute: access_token != null ? '/home' : '/login',
    router: router,
  ));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  MyApp({required this.router});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Musewave',
      routerConfig: router,
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
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        iconTheme: IconThemeData(color: Colors.black),
        hintColor: Colors.black,
        useMaterial3: true,
      ),
      // routes: {
      //   '/': (context) => HomePage(title: 'Musewave'),
      //   '/login': (context) => LoginPage(),
      //   '/home': (context) => HomePage(title: 'Musewave'),
      //   // '/search': (context) => (),
      //   '/user': (context) => PersonalPage(),
      //   // Add more routes as needed
      // },
    );
  }
}
