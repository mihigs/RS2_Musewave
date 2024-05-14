import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/DTOs/ArtistDetailsDto.dart';
import 'package:frontend/services/artist_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/widgets/collection/collection_list_item.dart';
import 'package:frontend/models/base/streaming_context.dart';

class ArtistPage extends StatefulWidget {
  final int artistId;
  final bool isJamendoArtist;

  const ArtistPage(
      {Key? key, required this.artistId, this.isJamendoArtist = false})
      : super(key: key);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  late Future<ArtistDetailsDto> artistFuture;
  final ArtistService artistService = GetIt.I<ArtistService>();

  @override
  void initState() {
    super.initState();
    artistFuture =
        artistService.getArtistDetails(widget.artistId, widget.isJamendoArtist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
        title: const Text('Artist'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: FutureBuilder<ArtistDetailsDto>(
        future: artistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var artistDetails = snapshot.data!;
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    var top = constraints.biggest.height;
                    // Calculate opacity for image to be opposite of text, fading as user scrolls down
                    var imageOpacity = ((top - 80.0) / 220.0).clamp(0.0, 1.0);
                    // Calculate shadow opacity to disappear as user scrolls down
                    var shadowOpacity = imageOpacity;
                    return FlexibleSpaceBar(
                      title: Text(
                        artistDetails.artist.user!.userName,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Opacity(
                            opacity: imageOpacity,
                            child: artistDetails.artist.artistImageUrl != null && artistDetails.artist.artistImageUrl!.isNotEmpty
                                ? Image.network(
                                    artistDetails.artist.artistImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.person,
                                    size: 128, color: Colors.white),
                          ),
                          // Adding a gradient overlay as shadow
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.9 *
                                      shadowOpacity), // stronger shadow at the bottom
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = artistDetails.tracks[index];
                    return CollectionListItem(
                      StreamingContext(
                        track,
                        widget.artistId,
                        StreamingContextType.ARTIST,
                      ),
                    );
                  },
                  childCount: artistDetails.tracks.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
