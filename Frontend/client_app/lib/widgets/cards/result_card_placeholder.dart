import 'package:flutter/material.dart';
import 'package:frontend/models/constants/result_card_types.dart';

class ResultCardPlaceholder extends StatelessWidget {
  final ResultCardType type;

  ResultCardPlaceholder({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 275,
      width: 275,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (type) {
      case ResultCardType.Track:
        return [Colors.blue, Colors.lightBlueAccent];
      case ResultCardType.Album:
        return [Colors.green, Colors.lightGreenAccent];
      case ResultCardType.Artist:
        return [Colors.red, Colors.pinkAccent];
      case ResultCardType.Playlist:
        return [Colors.orange, Colors.deepOrangeAccent];
      default:
        return [Colors.deepPurple, Colors.purpleAccent];
    }
  }
}
