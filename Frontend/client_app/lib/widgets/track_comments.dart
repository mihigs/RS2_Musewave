import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/collection/comment_item.dart';
import 'package:get_it/get_it.dart';

class TrackCommentsModal extends StatefulWidget {
  final String trackId;

  TrackCommentsModal({Key? key, required this.trackId}) : super(key: key);

  @override
  _TrackCommentsModalState createState() => _TrackCommentsModalState();
}

class _TrackCommentsModalState extends State<TrackCommentsModal> {
  final TracksService tracksService = GetIt.I<TracksService>();
  late Future<List<Comment>> commentsFuture;
  final TextEditingController _commentController = TextEditingController();
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    commentsFuture = tracksService.getTrackComments(int.parse(widget.trackId));
  }

  void _addComment() async {
    if (_characterCount > 0 && _characterCount <= 500) {
      Comment? newComment = await tracksService.addTrackComment(
        int.parse(widget.trackId),
        _commentController.text,
      );
      if (newComment != null) {
        setState(() {
          commentsFuture = commentsFuture.then((comments) async {
            var updatedComments = List<Comment>.from(comments);
            updatedComments.insert(0, newComment);
            return updatedComments;
          });
          _commentController.clear();
          _characterCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Comments Found"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Comment comment = snapshot.data![index];
                    return CommentItem(comment: comment);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _commentController,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: "Add a comment",
                counterText: "${_characterCount}/500",
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _characterCount = value.length;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
