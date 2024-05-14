import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/TrackUploadDto.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/helpers/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class UploadMediaPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final AuthenticationService authService = GetIt.I<AuthenticationService>();
  final SignalRService signalrService = GetIt.I<SignalRService>();

  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  final _formKey = GlobalKey<FormState>();
  String _trackName = '';
  late PlatformFile _selectedFile;
  bool _fileReady = false;
  bool _isUploading = false; // New state variable to track upload status
  int maximumFileSize = 10000000; // 10MB
  String _uploadMessage =
      "Select a track and give it a name to get started..."; // To display success or error messages

  Future<void> _uploadFile() async {
    // Ask for permissions
    if(!kIsWeb){
      await requestStoragePermission();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['mp3', 'wav', 'mid', 'midi'],
    );

    setState(() {
      _isUploading = true; // Start uploading
      _setUploadMessage(""); // Reset upload message
    });

    if (result != null) {
      if (result.files.first.size > maximumFileSize) {
        _showSnackBar(
            'File is too big. Please select a file smaller than 10MB.');
      } else if (result.files.first.size == 0) {
        _showSnackBar('File is empty. Please select a file with content.');
      } else {
        _selectedFile = result.files.first;
        _fileReady = true;
        _setUploadMessage("Track uploaded successfully!");
      }
    }
    setState(() {
      _isUploading = false; // End uploading
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // Handler which listens to signalR for track processing status
  void _initializeTrackProcessingStatusHandler() {
    widget.signalrService.registerTrackUploadFailed((data) => _setUploadMessage(
        "Track processing has unfortunately failed. Please try uploading again."));
    widget.signalrService.registerOnTrackReady(
        (data) => _setUploadMessage("Track processed successfuly!"));
  }

  void _setUploadMessage(String message) {
    setState(() {
      _uploadMessage = message;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }
    _setUploadMessage("Processing track...");

    String? userId = await widget.authService.getUserIdFromStorage();

    if (userId == null) {
      return;
    }

    var trackMetaData = TrackUploadDto(
      trackName: _trackName,
      userId: userId,
    );

    var result = await widget.tracksService.uploadTrack(
      trackMetaData,
      _selectedFile,
    );

    if(!result){
      _setUploadMessage(
        "Track processing has unfortunately failed. Please try uploading again.");
    }
  }

  bool _validate() {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate() && _fileReady && !_isUploading) {
        _formKey.currentState!.save();
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _initializeTrackProcessingStatusHandler();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isUploading // Disable back button when uploading
            ? Container() // Empty container effectively hides the button
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  if (GoRouter.of(context).canPop()) {
                    GoRouter.of(context).pop();
                  } else {
                    GoRouter.of(context).go('/');
                  }
                },
              ),
        title: Text('Upload Track'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title for the track';
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (_isUploading) ...[
                      LinearProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Uploading track..."),
                    ],
                    SizedBox(height: 10),
                    Text(_uploadMessage, textAlign: TextAlign.center),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text('Select Media'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _uploadFile,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text('Submit'),
                      onPressed: _validate()
                          ? () {
                              if (_formKey.currentState != null && _validate()) {
                                _submit();
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
