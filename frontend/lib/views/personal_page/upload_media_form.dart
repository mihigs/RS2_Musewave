import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/DTOs/TrackUploadDto.dart';
import 'package:frontend/services/authentication_service.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadMediaPage extends StatefulWidget {
  final TracksService tracksService = GetIt.I<TracksService>();
  final AuthenticationService authService = GetIt.I<AuthenticationService>();

  @override
  _UploadMediaPageState createState() => _UploadMediaPageState();
}

class _UploadMediaPageState extends State<UploadMediaPage> {
  final _formKey = GlobalKey<FormState>();
  String _trackName = '';
  late PlatformFile _selectedFile;
  bool _fileReady = false;
  int maximumFileSize = 10000000; // 10MB

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'mid', 'midi'],
    );

    // check if the file is bigger than maximumFileSize
    if (result != null ) {
      if(result.files.first.size > maximumFileSize){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is too big. Please select a file smaller than 10MB.'),
          ),
        );
      return;
      } else if (result.files.first.size == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is empty. Please select a file with content.'),
          ),
        );
        return;
      }
      _selectedFile = result.files.first;
      setState(() {
        _fileReady = true;
      });

      print(_selectedFile.name);
      print(_selectedFile.bytes);
      print(_selectedFile.size);
      print(_selectedFile.extension);
    }
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    String? userId = await widget.authService.getUserIdFromStorage();

    if (userId == null) {
      return;
    }

    // create a new TrackUploadDto
    var trackMetaData = TrackUploadDto(
      trackName: _trackName,
      userId: userId,
    );

    widget.tracksService.uploadTrack(
      trackMetaData,
      _selectedFile,
    );

  }

  bool _validate() {
    if (_formKey.currentState != null){
      if (_formKey.currentState!.validate() && _fileReady) {
        _formKey.currentState!.save();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBar(
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
              title: Text('Upload Track'),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Track Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the track name';
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
                  // Container(
                  //   width: double.infinity,
                  //   child: DropdownButton<String>(
                  //     items: <String>['Album']
                  //         .map<DropdownMenuItem<String>>((String value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value,
                  //         child: Text(value),
                  //       );
                  //     }).toList(),
                  //     onChanged: null,
                  //     hint: Text('Select Album'),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text('Select Media'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: _uploadFile,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: ElevatedButton(
                      child: Text('Submit'),
                      onPressed: _validate() ? () {
                        // Dynamically check if form is valid and file is ready. Trigger submission or do nothing accordingly.
                        if (_formKey.currentState != null && _validate()) {
                          _submit();
                        }
                      } : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
