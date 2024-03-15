import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/album_service.dart';
import 'package:frontend/services/artist_service.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/base/api_service.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  final artistService = await getIt.registerSingleton(ArtistService(secureStorage));
  final playlistService = await getIt.registerSingleton(PlaylistService(secureStorage));

  // Get the token from secure storage
  final access_token = await authService.checkLocalStorageForToken();

  final router = routerGenerator(authService.getLoggedInState());

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
        iconTheme: IconThemeData(color: Colors.black),
        hintColor: Colors.black,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
