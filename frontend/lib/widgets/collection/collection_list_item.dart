import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/base/streaming_context.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class CollectionListItem extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final StreamingContext _streamingContext;

  CollectionListItem(this._streamingContext, {super.key});

  Track get track => _streamingContext.track;
  StreamingContext get streamingContext => _streamingContext;

  @override
  State<CollectionListItem> createState() => _CollectionListItemState();
}

class _CollectionListItemState extends State<CollectionListItem> {
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    updateIsPlaying();
  }

  void updateIsPlaying() {
    setState(() {
      isPlaying = Provider.of<MusicStreamer>(context, listen: false).isPlaying;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to the MusicStreamer and update isPlaying when it changes
    Provider.of<MusicStreamer>(context, listen: false)
        .addListener(updateIsPlaying);
  }

  @override
  void dispose() {
    // Remove the listener from the provider before disposing the widget
    Provider.of<MusicStreamer>(context, listen: false)
        .removeListener(updateIsPlaying);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying =
        Provider.of<MusicStreamer>(context, listen: false).isPlaying;
    // final trackLoaded =
    //     Provider.of<MusicStreamer>(context, listen: false).trackLoaded;
    final currentPlayingTrackId =
        Provider.of<MusicStreamer>(context, listen: false).currentTrack?.id;
    bool isLiked = widget.track.isLiked ?? false;
    final model = Provider.of<MusicStreamer>(context, listen: false);

    return Container(
      color: Colors.grey.withOpacity(0.15),
      margin: EdgeInsets.only(bottom: 1),
      height: 85,
      child: Center(
        child: ListTile(
          leading: IconButton(
            icon: Icon(isPlaying && (currentPlayingTrackId == widget.track.id)
                ? Icons.pause
                : Icons.play_arrow),
            onPressed: () async {
              final streamer =
                  Provider.of<MusicStreamer>(context, listen: false);

              if (isPlaying) {
                if (currentPlayingTrackId != widget.track.id) {
                  await streamer.stop();
                  await streamer.startTrack(widget.streamingContext);
                } else {
                  await streamer.pause();
                }
              } else {
                await streamer.startTrack(widget.streamingContext);
              }

              updateIsPlaying();
            },
          ),
          title: Text(widget.track.artist!.user!.userName),
          subtitle: Text(widget.track.title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatDuration(widget.track.duration ?? 0),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(isLiked ? Icons.star : Icons.star_border, size: 32),
                onPressed: () async {
                  setState(() {
                    isLiked = !isLiked;
                    model.currentTrack?.isLiked = isLiked;
                  });
                  await widget.tracksService.toggleLikeTrack(widget.track.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
