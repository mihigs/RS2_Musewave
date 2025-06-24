import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/mood_tracker.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/mood_tracker_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({Key? key}) : super(key: key);

  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  late Future<List<MoodTracker>> moodTrackerFuture;
  final MoodTrackerService moodTrackerService = GetIt.I<MoodTrackerService>();

  @override
  void initState() {
    super.initState();
    moodTrackerFuture = moodTrackerService.getMoodTrackers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () async {
                  await GoRouter.of(context).push(Routes.newMoodRecord);
                  moodTrackerFuture = moodTrackerService.getMoodTrackers();
                },
                child: Text('Record'))
          ],
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
          title: const Text('Mood Tracker List'),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: FutureBuilder<List<MoodTracker>>(
          future: moodTrackerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var moodTrackers = snapshot.data!;

            return ListView.builder(
                itemCount: moodTrackers.length,
                itemBuilder: (context, index) {
                  final moodTrackerItem = moodTrackers[index];

                  return ListTile(
                    title: Text('Mood: ${moodTrackerItem.moodType.name}'),
                    subtitle: Text('User: ${moodTrackerItem.user.userName}'),
                    trailing:
                        Text(moodTrackerItem.recordDate.toIso8601String()),
                  );
                });
          },
        ));
  }
}
