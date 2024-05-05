import 'package:flutter/material.dart';
import 'package:frontend/models/base/logged_in_state_info.dart';
import 'package:frontend/views/album_page.dart';
import 'package:frontend/views/artist_page.dart';
import 'package:frontend/views/home_page.dart';
import 'package:frontend/views/login_page.dart';
import 'package:frontend/views/media_player_page.dart';
import 'package:frontend/views/personal_page/personal_page.dart';
import 'package:frontend/views/personal_page/upload_media_form.dart';
import 'package:frontend/views/playlist_page.dart';
import 'package:frontend/views/search_view.dart';
import 'package:frontend/views/track_page.dart';
import 'package:frontend/widgets/containers/persistent_player_container.dart';
import 'package:frontend/widgets/tracks_collection.dart';
import 'package:frontend/widgets/containers/navigation_container.dart';
import 'package:go_router/go_router.dart';

GoRouter routerGenerator(LoggedInStateInfo loggedInState) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: loggedInState,
    redirect: (BuildContext context, GoRouterState state) {
      final isOnLogin = state.uri.toString() == Routes.login;
      final isOnSignUp = state.uri.toString() == Routes.signup;
      final isLoggedIn = loggedInState.isLoggedIn;

      if (!isOnLogin && !isOnSignUp && !isLoggedIn) return Routes.login;
      if ((isOnLogin || isOnSignUp) && isLoggedIn) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signup,
        builder: (_, __) => PersistentPlayerContainer(child: LoginPage()),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => ContainerWithNavigation(),
      ),
      GoRoute(
        path: '${Routes.track}/:trackId/:contextId/:contextType',
        builder: (context, state) {
          final trackId = state.pathParameters['trackId'];
          final contextId = state.pathParameters['contextId'];
          final contextType = state.pathParameters['contextType'];
          return MediaPlayerPage(
            trackId: trackId!,
            contextId: contextId!,
            contextType: contextType!,
          );
        },
      ),
      GoRoute(
        path: '${Routes.album}/:albumId',
        builder: (context, state) {
          final albumId = state.pathParameters['albumId'];
          return PersistentPlayerContainer(
            child: AlbumPage(
              albumId: int.parse(albumId!),
            ),
          );
        },
      ),
      GoRoute(
        path: '${Routes.artist}/:artistId/:isJamendoArtist',
        builder: (context, state) {
          final artistId = state.pathParameters['artistId'];
          final isJamendoArtist = state.pathParameters['isJamendoArtist'] == 'true' ? true : false;
          return PersistentPlayerContainer(
            child: ArtistPage(
              artistId: int.parse(artistId!),
              isJamendoArtist: isJamendoArtist
            ),
          );
        },
      ),
      GoRoute(
        path: '${Routes.playlist}/:playlistId/:isExploreWeekly',
        builder: (context, state) {
          final playlistId = state.pathParameters['playlistId'];
          final isExploreWeekly = state.pathParameters['isExploreWeekly'] == 'true' ? true : false;
          return PersistentPlayerContainer(
            child: PlaylistPage(
              playlistId: int.parse(playlistId!),
              isExploreWeekly: isExploreWeekly
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.liked,
        builder: (context, state) {
          return PersistentPlayerContainer(
            child: PlaylistPage(),
          );
        },
      ),
      GoRoute(
        path: Routes.uploadMedia,
        builder: (_, __) => PersistentPlayerContainer(child: UploadMediaPage()),
      ),
    ],
  );
}

abstract class Routes {
  static const signup = '/signup';
  static const login = '/login';
  static const home = '/';
  static const search = '/search';
  static const profile = '/profile';
  static const uploadMedia = '/profile/upload';
  static const track = '/track';
  static const album = '/album';
  static const artist = '/artist';
  static const playlist = '/playlist';
  static const liked = '/liked';
}
