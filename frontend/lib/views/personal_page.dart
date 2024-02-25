import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class PersonalPage extends StatefulWidget {
  PersonalPage({super.key});

  final AuthenticationService authService = GetIt.I<AuthenticationService>();


  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await widget.authService.logout();
                  GoRouter.of(context).go(Routes.home);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                      double.infinity, 50), // this makes the button full width.
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
