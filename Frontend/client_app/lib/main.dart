import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/streaming/music_streamer.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/artist_service.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/shared/signalr_listener.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/signalr_service.dart';

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
  final signalRService = getIt.registerSingleton<SignalRService>(SignalRService(signalrHubURL));

  // Register services
  getIt.registerSingleton(ApiService(secureStorage: secureStorage));
  getIt.registerSingleton(TracksService(secureStorage));
  getIt.registerSingleton(AlbumService(secureStorage));
  getIt.registerSingleton(ArtistService(secureStorage));
  getIt.registerSingleton(PlaylistService(secureStorage));
  getIt.registerSingleton(DashboardService(secureStorage));
  final authService = getIt.registerSingleton(AuthenticationService(secureStorage: secureStorage));

  // Get the token from secure storage
  final accessToken = await authService.checkLocalStorageForToken();

  // Initialize SignalR connection if the user is logged in
  if(accessToken != null && !signalRService.isInitialized){
    await signalRService.initializeConnection(accessToken);
  }

  // Initialize Router
  final router = routerGenerator(authService.getLoggedInState());
  getIt.registerSingleton<GoRouter>(router);

  runApp(ChangeNotifierProvider(
    create: (context) => MusicStreamer(),
    child: MyApp(
      router: router,
    ),
  ));
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
        return SignalRListenerWidget(
          router: router!
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
