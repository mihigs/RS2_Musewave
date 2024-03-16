import 'package:flutter/material.dart';
import 'package:frontend/widgets/persistent_player.dart';

class PersistentPlayerContainer extends StatelessWidget {
  final Widget child;

  const PersistentPlayerContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          Container(
            height: 75,
            child: Stack(
              children: [Positioned(bottom: 0, child: PersistentPlayer())]),
          ),
        ],
      ),
    );
  }
}
