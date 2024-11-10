import 'package:flutter/material.dart';
import 'package:frontend/models/track.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditTrackPage extends StatefulWidget {
  final int trackId;

  EditTrackPage({required this.trackId});

  @override
  _EditTrackPageState createState() => _EditTrackPageState();
}

class _EditTrackPageState extends State<EditTrackPage> {
  final _formKey = GlobalKey<FormState>();
  String _trackName = '';
  bool _isLoading = false;
  late Track _track;
  final TracksService tracksService = GetIt.I<TracksService>();

  @override
  void initState() {
    super.initState();
    _fetchTrack();
  }

  Future<void> _fetchTrack() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _track = await tracksService.getTrack(widget.trackId);
      setState(() {
        _trackName = _track?.title ?? '';
      });
    } catch (e) {
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.generic_error)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    if (_track != null) {
      setState(() {
        _isLoading = true;
      });
      _track!.title = _trackName;
      bool result = false;
      try {
        if (_track != null) {
          result = await tracksService.updateTrack(_track!);
        }
        if (result) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.track_update_success)),
          );
          // Navigate back
          GoRouter.of(context).pop();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.generic_error)),
          );
        }
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.generic_error}: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validate() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        return true;
      }
    }
    return false;
  }

  bool _isFormValid() {
    return _trackName.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
        title: Text(AppLocalizations.of(context)!.edit),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _track == null
              ? Center(child: Text(AppLocalizations.of(context)!.no_tracks))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _trackName,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.track_title,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.track_title_hint;
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _trackName = value!;
                          },
                          onChanged: (value) {
                            setState(() {
                              _trackName = value;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isFormValid() && !_isLoading ? _submit : null,
                          child: Text(AppLocalizations.of(context)!.confirm),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
