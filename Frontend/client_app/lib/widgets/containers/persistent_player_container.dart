import 'package:flutter/material.dart';
import 'package:frontend/streaming/music_streamer.dart';
import 'package:frontend/widgets/persistent_player.dart';
import 'package:provider/provider.dart';

class PersistentPlayerContainer extends StatelessWidget {
  final Widget child;

  const PersistentPlayerContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MusicStreamer>(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          if (model.trackLoaded) Container(
            height: 75,
            child: Stack(
              children: [Positioned(bottom: 0, child: PersistentPlayer())]),
          ),
        ],
      ),
    );
  }
}
