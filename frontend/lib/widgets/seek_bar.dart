import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class SeekBar extends StatefulWidget {
  SeekBar();

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  @override
  Widget build(BuildContext context) {
    final MusicStreamer streamer = Provider.of<MusicStreamer>(context);

    return StreamBuilder<Duration>(
      stream: streamer.getPositionStream(),
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: streamer.getBufferedPositionStream(),
          builder: (context, bufferedPositionSnapshot) {
            final double totalDurationValue = streamer.getDuration()?.inMilliseconds.toDouble() ?? 1.0;
            final double positionValue = positionSnapshot.data?.inMilliseconds.toDouble() ?? 0.0;
            final double bufferedPositionValue = bufferedPositionSnapshot.data?.inMilliseconds.toDouble() ?? 0.0;

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(formatDuration((positionValue ~/ 1000).toInt()), style: TextStyle(fontSize: 10)),
                      Expanded(
                        child: Container(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              Transform.translate(
                                offset: Offset(30, 0), // Apply the horizontal translation
                                child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2.0,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
                                  activeTrackColor: Colors.grey, // Buffered color
                                  inactiveTrackColor: Colors.grey.shade300,
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(right: 50),
                                  child: Slider(
                                    min: 0.0,
                                    max: totalDurationValue,
                                    value: bufferedPositionValue.clamp(0.0, totalDurationValue),
                                    onChanged: null, // Making this slider non-interactive
                                  ),
                                ),
                                ),
                              ),
                              SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 2.0,
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                  activeTrackColor: Colors.blue, // Playback position color
                                  inactiveTrackColor: Colors.transparent, // Making unplayed portion transparent
                                ),
                                child: Slider(
                                  min: 0.0,
                                  max: totalDurationValue,
                                  value: positionValue.clamp(0.0, totalDurationValue),
                                  onChanged: (value) {
                                    setState(() {
                                      streamer.seek(Duration(milliseconds: value.toInt()));
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    setState(() {
                                      streamer.seek(Duration(milliseconds: value.toInt()));
                                      streamer.play();
                                    });
                                  },
                                  onChangeStart: (value) {
                                    streamer.pause(gradually: false);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(formatDuration((totalDurationValue ~/ 1000).toInt()), style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
