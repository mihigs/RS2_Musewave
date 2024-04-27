import 'package:flutter/material.dart';
import 'package:admin_app/router.dart';
import 'package:admin_app/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class PersonalPage extends StatelessWidget {
  final AuthenticationService authService = GetIt.I<AuthenticationService>();

  @override
  Widget build(BuildContext context) {
    // Implement your PersonalPage widget here
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () async {
                await authService.logout();
                GoRouter.of(context).go(Routes.login);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 50), // this makes the button full width.
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
