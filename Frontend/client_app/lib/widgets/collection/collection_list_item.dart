import 'package:flutter/material.dart';
import 'package:frontend/helpers/helper_functions.dart';
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
  MusicStreamer? musicStreamer;
  bool isPlaying = false;
  late bool isLiked = widget.track.isLiked ?? false;

  @override
  void initState() {
    super.initState();
    musicStreamer = Provider.of<MusicStreamer>(context, listen: false);
    updateIsPlaying();
  }

  void updateIsPlaying() {
    setState(() {
      if(musicStreamer != null){
        isPlaying = musicStreamer!.isPlaying;
      }
    });
  }

  void updateIsLiked() {
    setState(() {
      if(musicStreamer != null){
        int currentTrackId = musicStreamer!.currentTrack?.id ?? 0;
        if (widget.track.id == currentTrackId){
          isLiked = musicStreamer!.isLiked;
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (musicStreamer != null) {
      musicStreamer!.addListener(updateIsPlaying);
      musicStreamer!.addListener(updateIsLiked);
    }
  }

  @override
  void dispose() {
    musicStreamer!.removeListener(updateIsPlaying);
    musicStreamer!.removeListener(updateIsLiked);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = musicStreamer!;
    final isPlaying = musicStreamer!.isPlaying;
    final currentPlayingTrackId = musicStreamer!.currentTrack?.id;

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
              if(musicStreamer != null){
                widget.streamingContext.track.isLiked = isLiked;
                if (isPlaying) {
                  if (currentPlayingTrackId != widget.track.id) {
                    await musicStreamer!.stop();
                    await musicStreamer!.startTrack(widget.streamingContext);
                  } else {
                    await musicStreamer!.pause();
                  }
                } else {
                  await musicStreamer!.startTrack(widget.streamingContext);
                }
              }
              updateIsPlaying();
            },
          ),
          title: Text(overflow: TextOverflow.clip, widget.track.title),
          subtitle: Text(overflow: TextOverflow.clip, widget.track.artist!.user!.userName),
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
                  widget.tracksService.toggleLikeTrack(widget.track.id).then((response) => {
                    if (response) {
                      setState(() {
                        isLiked = !isLiked;
                      }),
                      if(widget.track.id == model.currentTrack?.id){
                        model.toggleIsLiked(),
                      }else if(widget.track.id == model.nextTrack?.id){
                        model.nextTrack!.isLiked = !model.nextTrack!.isLiked!
                      },
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
