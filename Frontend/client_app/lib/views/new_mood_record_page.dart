import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/DTOs/MoodTrackerDto.dart';
import 'package:frontend/models/constants/mood_types.dart';
import 'package:frontend/models/mood_tracker.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/router.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/mood_tracker_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class NewMoodRecordPage extends StatefulWidget {
  const NewMoodRecordPage({Key? key}) : super(key: key);

  @override
  _NewMoodRecordPageState createState() => _NewMoodRecordPageState();
}

class _NewMoodRecordPageState extends State<NewMoodRecordPage> {
  late Future<List<User>> usersFuture;
  final MoodTrackerService moodTrackerService = GetIt.I<MoodTrackerService>();
  final AuthenticationService authenticationService =
      GetIt.I<AuthenticationService>();
  final _formKey = GlobalKey<FormState>();

  User? selectedUser;
  DateTime selectedDate = DateTime.now();
  MoodType? selectedMood;
  String? description;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await moodTrackerService.recordMood(
          selectedUser!.id, selectedMood!, selectedDate, description);
      GoRouter.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    usersFuture = authenticationService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () =>
                    {GoRouter.of(context).push(Routes.newMoodRecord)},
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
          title: const Text('Record a mood'),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: FutureBuilder<List<User>>(
          future: usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            var users = snapshot.data!;

            return Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                  key: _formKey,
                  child: Column(children: [
                    DropdownButtonFormField(
                      items: users
                          .map((u) => DropdownMenuItem<User>(
                                child: Text(u.userName),
                                value: u,
                              ))
                          .toList(),
                      decoration: InputDecoration(labelText: "User"),
                      value: selectedUser,
                      onChanged: (value) => {
                        setState(() {
                          selectedUser = value;
                        })
                      },
                      validator: (value) =>
                          value == null ? 'User is required' : null,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField(
                      items: MoodType.values
                          .map((u) => DropdownMenuItem<MoodType>(
                                child: Text(u.name),
                                value: u,
                              ))
                          .toList(),
                      value: selectedMood,
                      onChanged: (value) => {
                        setState(
                          () => selectedMood = value,
                        )
                      },
                      decoration: InputDecoration(labelText: "Mood type"),
                      validator: (value) =>
                          value == null ? 'Mood is required' : null,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now());

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                            decoration: InputDecoration(labelText: 'Date'),
                            child: Text(selectedDate.toIso8601String()))),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      decoration:
                          InputDecoration(labelText: "Description (optional)"),
                      maxLines: 5,
                      onChanged: (newValue) {
                        description = newValue;
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _submit, child: Text("Submit")))
                  ])),
            );
          },
        ));
  }
}
