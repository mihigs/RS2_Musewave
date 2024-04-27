import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:admin_app/router.dart';
// import 'package:admin_app/services/artist_service.dart';
import 'package:admin_app/services/authentication_service.dart';
import 'package:admin_app/services/base/api_service.dart';
// import 'package:admin_app/widgets/shared/signalr_listener.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:admin_app/services/signalr_service.dart';

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
  GoRouter.optionURLReflectsImperativeAPIs = true;
  const String signalrHubURL = String.fromEnvironment('SIGNALR_HUB_URL');

  final getIt = GetIt.instance;

  // Allow network requests to localhost over HTTP
  HttpOverrides.global = MyHttpOverrides();

  // Register secure storage
  final secureStorage = getIt.registerSingleton(const FlutterSecureStorage());

  // Initialize and register the SignalRServices
  // final signalRService = getIt.registerSingleton<SignalRService>(SignalRService(signalrHubURL));

  // Register services
  getIt.registerSingleton(ApiService(secureStorage: secureStorage));
  final authService = getIt.registerSingleton(AuthenticationService(secureStorage: secureStorage));

  // Get the token from secure storage
  final accessToken = await authService.checkLocalStorageForToken();

  // Initialize SignalR connection if the user is logged in
  // if(accessToken != null && !signalRService.isInitialized){
  //   await signalRService.initializeConnection(accessToken);
  // }

  // Initialize Router
  final router = routerGenerator(authService.getLoggedInState());
  getIt.registerSingleton<GoRouter>(router);

  runApp(
    MyApp(
      router: router,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  MyApp({required this.router});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Musewave',
      routerConfig: router,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black),
        hintColor: Colors.black,
        useMaterial3: true,
      ),
      builder: (context, router) {
        // Wrap the router with the SignalRListenerWidget
        // return SignalRListenerWidget(
        return Container(
          child: router!
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
