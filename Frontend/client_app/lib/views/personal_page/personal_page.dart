import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/views/personal_page/tabs/my_music_tab.dart';
import 'package:frontend/views/personal_page/tabs/playlists_tab.dart';
import 'package:frontend/views/personal_page/tabs/profile_tab.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PersonalPage extends StatelessWidget {
  final AuthenticationService authService = GetIt.I<AuthenticationService>();

  PersonalPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<User>(
          future: authService.getUserDetails(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Expanded(child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Expanded(child: Text('Error: ${snapshot.error}'));
            } else {
              User user = snapshot.data!;
              return DefaultTabController(
                length: 3,
                child: Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(user
                                  .userName)), // Display the user's full name
                          IconButton(
                            icon: Icon(Icons.queue),
                            onPressed: () {
                              GoRouter.of(context).push(Routes.uploadMedia);
                            },
                          ),
                        ],
                      ),
                      bottom: TabBar(
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.profile),
                          Tab(text: AppLocalizations.of(context)!.playlists),
                          Tab(text: AppLocalizations.of(context)!.my_music),
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: [
                        ProfileTab(),
                        PlaylistsTab(),
                        MyMusicTab(),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
