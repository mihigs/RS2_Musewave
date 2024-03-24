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
    MusicStreamer streamer = Provider.of<MusicStreamer>(context, listen: false);

    return StreamBuilder<Duration>(
      stream: streamer.getPositionStream(),
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: streamer.getBufferedPositionStream(),
          builder: (context, bufferedPositionSnapshot) {
            double totalDurationValue =
                streamer.getDuration()?.inMilliseconds.toDouble() ?? 1.0;
            double positionValueInitial =
                positionSnapshot.data?.inMilliseconds.toDouble() ?? 0.0;
            double positionValue = positionValueInitial > totalDurationValue
                ? 0
                : positionValueInitial;

            return Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatDuration((positionValue ~/ 1000).toInt()), style: TextStyle(fontSize: 10)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 10.0, // Adjust the thickness here
                          ),
                          child: Slider(
                            min: 0.0,
                            max: totalDurationValue,
                            value: positionValue,
                            onChanged: (value) {
                              setState(() {
                                streamer
                                    .seek(Duration(milliseconds: value.toInt()));
                              });
                            },
                            onChangeEnd: (value) {
                              setState(() {
                                streamer
                                    .seek(Duration(milliseconds: value.toInt()));
                                streamer.play();
                              });
                            },
                            onChangeStart: (value) {
                              streamer.pause();
                            },
                            divisions: totalDurationValue.toInt(),
                            label:
                                '${formatDuration((positionValue ~/ 1000).toInt())} / ${formatDuration((totalDurationValue ~/ 1000).toInt())}',
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
