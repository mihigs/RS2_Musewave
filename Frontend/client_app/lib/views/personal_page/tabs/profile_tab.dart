import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ProfileTab extends StatelessWidget {
  final AuthenticationService authService = GetIt.I<AuthenticationService>();

  ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                authService.logout();
                GoRouter.of(context).go(Routes.login);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                    double.infinity, 50),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
