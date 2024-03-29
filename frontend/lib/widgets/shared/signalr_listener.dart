import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/services/signalr_service.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class SignalRListenerWidget extends StatefulWidget {
  final Widget child;

  SignalRListenerWidget({required this.child});

  @override
  _SignalRListenerWidgetState createState() => _SignalRListenerWidgetState();
}

// This widget is used to listen for relevant SignalR events and show a snackbar when they occur
class _SignalRListenerWidgetState extends State<SignalRListenerWidget> {
  late final SignalRService _signalRService;

  @override
  void initState() {
    super.initState();
    _signalRService = GetIt.instance.get<SignalRService>();

    _signalRService.setOnConnectionEstablishedCallback(() {
      _signalRService.registerOnTrackReady((data) {
        _showSnackBar("Your track is ready!");
      });
      // other events can be added here...
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // This widget doesn't affect the tree, it just listens for SignalR events
    return widget.child;
  }
}
