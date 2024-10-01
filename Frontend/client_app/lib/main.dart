import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/services/language_service.dart';
import 'package:frontend/services/payments_service.dart';
import 'package:frontend/services/search_service.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  const String signalrHubURL = String.fromEnvironment('SIGNALR_HUB_URL', defaultValue: 'http://10.0.2.2:8080/notificationHub');
  const String stripePublishableKey = String.fromEnvironment('STRIPE_PUBLIC_KEY', defaultValue: 'pk_test_51PZGBIRwyhx2IiJVM8aVdDPGk4po7vWjCuSJbQTS4H6hLqjpTd0EtNn70NhB7CwpVE7rBByBHtAtMCujDNd2Y3ck00QomHBSp0');

  final getIt = GetIt.instance;

  // Allow network requests to localhost over HTTP
  HttpOverrides.global = MyHttpOverrides();

  // Register secure storage
  final secureStorage = FlutterSecureStorage();
  getIt.registerSingleton(secureStorage);

  final currentLanguageCode = await secureStorage.read(key: 'language_code').then((value) => value ?? 'en');

  // Initialize and register the SignalRServices
  final signalRService = getIt.registerSingleton<SignalRService>(SignalRService(signalrHubURL));

  // Register services
  getIt.registerSingleton(ApiService(secureStorage: secureStorage));
  getIt.registerSingleton(TracksService(secureStorage));
  getIt.registerSingleton(AlbumService(secureStorage));
  getIt.registerSingleton(ArtistService(secureStorage));
  getIt.registerSingleton(PlaylistService(secureStorage));
  getIt.registerSingleton(DashboardService(secureStorage));
  getIt.registerSingleton(SearchService(secureStorage));
  getIt.registerSingleton(LanguageService(secureStorage));
  final paymentsService = getIt.registerSingleton(PaymentsService(secureStorage));
  final authService = getIt.registerSingleton(AuthenticationService(secureStorage: secureStorage));

  // Initialize Stripe
  paymentsService.initialize(stripePublishableKey);

  // Get the token from secure storage
  final accessToken = await authService.checkLocalStorageForToken();

  // Initialize SignalR connection if the user is logged in
  if (accessToken != null && !signalRService.isInitialized) {
    await signalRService.initializeConnection(accessToken);
  }

  // Initialize Router
  final router = routerGenerator(authService.getLoggedInState());
  getIt.registerSingleton<GoRouter>(router);

  runApp(ChangeNotifierProvider(
    create: (context) => MusicStreamer(),
    child: MyApp(
      router: router,
      currentLanguageCode: currentLanguageCode,
    ),
  ));
}

class MyApp extends StatefulWidget {
  final GoRouter router;
  final String currentLanguageCode;

  MyApp({required this.router, required this.currentLanguageCode});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.currentLanguageCode);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Musewave',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      routerConfig: widget.router,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black),
        hintColor: Colors.black,
        useMaterial3: true,
      ),
      builder: (context, router) {
        return SignalRListenerWidget(
          router: router!,
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
