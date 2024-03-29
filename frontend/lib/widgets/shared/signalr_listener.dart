import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:go_router/go_router.dart';

class SignalRListenerWidget extends StatefulWidget {
  final Widget router;
  final GoRouter goRouter = GetIt.I<GoRouter>();
  
  SignalRListenerWidget({required this.router});

  @override
  _SignalRListenerWidgetState createState() => _SignalRListenerWidgetState();
}

class _SignalRListenerWidgetState extends State<SignalRListenerWidget> {
  late final SignalRService _signalRService;

  @override
  void initState() {
    super.initState();
    _signalRService = GetIt.instance.get<SignalRService>();

    _signalRService.setOnConnectionEstablishedCallback(() {
      _signalRService.registerOnTrackReady((data) {
        //print data
        print(data);
        // Passing context directly might not work if initState() hasn't completed, so consider using another approach if necessary
        _showSnackBar(
          context,
          "Your track is ready!",
          action: SnackBarAction(
            label: 'Play',
            onPressed: () {
              widget.goRouter.go('/track/${data.trackId}/0/0');
            },
          ),
        );
      });
      _signalRService.registerTrackUploadFailed((data) {
        //print data
        print(data);
        // Passing context directly might not work if initState() hasn't completed, so consider using another approach if necessary
        _showSnackBar(
          context,
          "Track processing failed! Please try again."
        );
      });
      // other events can be added here...
    });
  }


  void _showSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), action: action));
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext newContext) {
        return widget.router;
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:frontend/services/signalr_service.dart';

// class SignalRListenerWidget extends StatefulWidget {
//   final Widget child;

//   SignalRListenerWidget({required this.child});

//   @override
//   _SignalRListenerWidgetState createState() => _SignalRListenerWidgetState();
// }

// // This widget is used to listen for relevant SignalR events and show a snackbar when they occur
// class _SignalRListenerWidgetState extends State<SignalRListenerWidget> {
//   late final SignalRService _signalRService;

//   @override
//   void initState() {
//     super.initState();
//     _signalRService = GetIt.instance.get<SignalRService>();

//     _signalRService.setOnConnectionEstablishedCallback(() {
//       _signalRService.registerOnTrackReady((data) {
//         _showSnackBar("Your track is ready!");
//       });
//       // other events can be added here...
//     });
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This widget doesn't affect the tree, it just listens for SignalR events
//     return widget.child;
//   }
// }
