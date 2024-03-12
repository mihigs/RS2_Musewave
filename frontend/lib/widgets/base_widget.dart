import 'package:flutter/material.dart';
import 'package:frontend/widgets/persistent_player.dart';

class BaseWidget extends StatelessWidget {
  final Widget child;

  const BaseWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Expanded(child: child),
          Positioned(bottom: 0, child: PersistentPlayer()),
        ],
      ),
    );
  }
}
