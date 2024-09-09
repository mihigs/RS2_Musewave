import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/services/signalr_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignalRListenerWidget extends StatefulWidget {
  final Widget router;
  final GoRouter goRouter = GetIt.I<GoRouter>();
  
  SignalRListenerWidget({super.key, required this.router});

  @override
  SignalRListenerWidgetState createState() => SignalRListenerWidgetState();
}

class SignalRListenerWidgetState extends State<SignalRListenerWidget> {
  late final SignalRService _signalRService;

  @override
  void initState() {
    super.initState();
    _signalRService = GetIt.instance.get<SignalRService>();

    _signalRService.startConnection();

    _signalRService.setOnConnectionEstablishedCallback(() {
      _signalRService.registerOnTrackReady((data) {
        _showSnackBar(
          context,
          AppLocalizations.of(context)!.track_is_ready,
          action: SnackBarAction(
            label: 'Play',
            onPressed: () {
              widget.goRouter.go('/track/${data.trackId}/0/0');
            },
          ),
        );
      });
      _signalRService.registerTrackUploadFailed((data) {
        _showSnackBar(
          context,
          AppLocalizations.of(context)!.track_processing_failed
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
