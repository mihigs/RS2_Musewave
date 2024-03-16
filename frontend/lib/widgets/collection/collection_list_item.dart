import 'package:flutter/material.dart';
import 'package:frontend/helpers/helperFunctions.dart';
import 'package:frontend/models/notifiers/music_streamer.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class CollectionListItem extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final Track track;

  CollectionListItem({required this.track});

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
  Provider.of<MusicStreamer>(context, listen: false).removeListener(updateIsPlaying);
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final isPlaying =
        Provider.of<MusicStreamer>(context, listen: false).isPlaying;
    final trackLoaded = Provider.of<MusicStreamer>(context, listen: false).trackLoaded;
    final currentPlayingTrackId = Provider.of<MusicStreamer>(context, listen: false).currentTrackId;
    bool isLiked = widget.track.isLiked ?? false;

    return Container(
      color: Colors.grey.withOpacity(0.15),
      margin: EdgeInsets.only(bottom: 1),
      height: 85,
      child: Center(
        child: ListTile(
          leading: IconButton(
            icon: Icon(isPlaying && (currentPlayingTrackId == widget.track.id) ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              if(isPlaying){
                if(currentPlayingTrackId == widget.track.id){
                  await Provider.of<MusicStreamer>(context, listen: false).pause();
                  return;
                } 
              }
              Track trackToPlay = await widget.tracksService.getTrack(widget.track.id);
              await Provider.of<MusicStreamer>(context, listen: false).initializeAndPlay(trackToPlay);
              updateIsPlaying();
              
              // if (isPlaying) {
              //   await Provider.of<MusicStreamer>(context, listen: false).pause();
              // } else if (trackLoaded){
              //   await Provider.of<MusicStreamer>(context, listen: false).play();
              // } else {
              //   Track trackToPlay = await tracksService.getTrack(widget.track.id);
              //   await Provider.of<MusicStreamer>(context, listen: false).initializeAndPlay(trackToPlay);
              // }
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
              icon: Icon(isLiked ? Icons.star : Icons.star_border,
                  size: 32),
              onPressed: () async {
                var snackBar;
                if (isLiked) {
                  var unlikedSuccessfuly = await widget.tracksService
                      .toggleLikeTrack(widget.track.id);
                  if (unlikedSuccessfuly) {
                    setState(() {
                      isLiked = false;
                    });
                  }
                } else {
                  var likedSuccessfuly = await widget.tracksService
                      .toggleLikeTrack(widget.track.id);
                  if (likedSuccessfuly) {
                    setState(() {
                      isLiked = true;
                    });
                    snackBar = const SnackBar(
                      content: Text('Added to favorites!'),
                      duration:
                          Duration(seconds: 1),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
              // IconButton(
              //   icon: Icon((isLiked != null && isLiked) ? Icons.star : Icons.star_border),
              //   onPressed: () async {
              //     if ((isLiked != null && isLiked)) {
              //       await Provider.of<TracksService>(context, listen: false)
              //           .toggleLikeTrack(widget.track.id);
              //     } else {
              //       await Provider.of<TracksService>(context, listen: false)
              //           .toggleLikeTrack(widget.track.id);
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text('Added to favorites!'),
              //           duration: Duration(seconds: 1),
              //         ),
              //       );
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
