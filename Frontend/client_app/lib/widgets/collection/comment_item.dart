import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  CommentItem({required this.comment});

  String _timeAgo(DateTime datetime) {
    final Duration diff = DateTime.now().difference(datetime);
    if (diff.inDays > 1) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 1) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(comment.user?.userName[0] ?? '?'),
      ),
      title: Text(comment.user?.userName ?? 'Unknown'),
      subtitle: Text(comment.text),
      trailing: Text(
        _timeAgo(comment.createdAt),
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
