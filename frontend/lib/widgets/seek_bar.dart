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
                          padding: EdgeInsets.only(right: 50),
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
                                child: Slider(
                                  min: 0.0,
                                  max: totalDurationValue,
                                  value: bufferedPositionValue.clamp(0.0, totalDurationValue),
                                  onChanged: null, // Making this slider non-interactive
                                ),
                                ),
                              ),
                              SliderTheme(
                                data: SliderThemeData(
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
                                    streamer.pause();
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


// import 'package:flutter/material.dart';
// import 'package:frontend/helpers/helperFunctions.dart';
// import 'package:frontend/models/notifiers/music_streamer.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:provider/provider.dart';

// class SeekBar extends StatefulWidget {
//   SeekBar();

//   @override
//   _SeekBarState createState() => _SeekBarState();
// }

// class _SeekBarState extends State<SeekBar> {
//   @override
//   Widget build(BuildContext context) {
//     MusicStreamer streamer = Provider.of<MusicStreamer>(context, listen: false);

//     return StreamBuilder<Duration>(
//       stream: streamer.getPositionStream(),
//       builder: (context, positionSnapshot) {
//         return StreamBuilder<Duration>(
//           stream: streamer.getBufferedPositionStream(),
//           builder: (context, bufferedPositionSnapshot) {
//             double totalDurationValue =
//                 streamer.getDuration()?.inMilliseconds.toDouble() ?? 1.0;
//             double positionValueInitial =
//                 positionSnapshot.data?.inMilliseconds.toDouble() ?? 0.0;
//             double positionValue = positionValueInitial > totalDurationValue
//                 ? 0
//                 : positionValueInitial;

//             return Container(
//               margin: EdgeInsets.only(left: 10, right: 10),
//               child: Column(
//                 children: [
//                   Row(
//                     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(formatDuration((positionValue ~/ 1000).toInt()), style: TextStyle(fontSize: 10)),
//                       Expanded(
//                         child: SliderTheme(
//                           data: SliderTheme.of(context).copyWith(
//                             trackHeight: 10.0, // Adjust the thickness here
//                           ),
//                           child: Slider(
//                             min: 0.0,
//                             max: totalDurationValue,
//                             value: positionValue,
//                             onChanged: (value) {
//                               setState(() {
//                                 streamer
//                                     .seek(Duration(milliseconds: value.toInt()));
//                               });
//                             },
//                             onChangeEnd: (value) {
//                               setState(() {
//                                 streamer
//                                     .seek(Duration(milliseconds: value.toInt()));
//                                 streamer.play();
//                               });
//                             },
//                             onChangeStart: (value) {
//                               streamer.pause();
//                             },
//                             divisions: totalDurationValue.toInt(),
//                             label:
//                                 '${formatDuration((positionValue ~/ 1000).toInt())} / ${formatDuration((totalDurationValue ~/ 1000).toInt())}',
//                           ),
//                         ),
//                       ),
//                       Text(formatDuration((totalDurationValue ~/ 1000).toInt()), style: TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
