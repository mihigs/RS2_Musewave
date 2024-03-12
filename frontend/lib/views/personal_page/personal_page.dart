import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/views/personal_page/tabs/my_music_tab.dart';
import 'package:frontend/views/personal_page/tabs/playlists_tab.dart';
import 'package:frontend/views/personal_page/tabs/profile_tab.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PersonalPage extends StatelessWidget {
  final AuthenticationService authService = GetIt.I<AuthenticationService>();

  PersonalPage({super.key});
  
  get http => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<User>(
          future: authService.getUserDetails(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
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
                            icon: Icon(Icons.note),
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'mp3',
                                  'wav',
                                  'mid',
                                  'midi'
                                ],
                              );

                              if (result != null) {
                                PlatformFile file = result.files.first;

                                print(file.name);
                                print(file.bytes);
                                print(file.size);
                                print(file.extension);

                                // Now you can use this file to upload
                                var request = http.MultipartRequest(
                                    'POST', Uri.parse('Your API Endpoint'));
                                request.files.add(http.MultipartFile.fromBytes(
                                  'file', // consider 'file' as a key for the API endpoint
                                  file.bytes!,
                                  filename: file.name,
                                  contentType:
                                      MediaType('audio', file.extension!),
                                ));

                                var response = await request.send();
                                if (response.statusCode == 200) {
                                  print('Uploaded!');
                                } else {
                                  print(
                                      'Failed to upload file: ${response.statusCode}');
                                }
                              } else {
                                // User canceled the picker
                              }
                            },
                          ),
                        ],
                      ),
                      bottom: const TabBar(
                        tabs: [
                          Tab(text: 'Profile'),
                          Tab(text: 'Playlists'),
                          Tab(text: 'My Music'),
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
