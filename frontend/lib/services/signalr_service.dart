import 'package:frontend/models/signalRMessages/track_processed_message.dart';
import 'package:frontend/models/signalRMessages/track_processing_failed_message.dart';
import 'package:signalr_core/signalr_core.dart';

class SignalRService {
  HubConnection? hubConnection;
  bool isConnected = false;
  bool isInitialized = false;
  final String hubUrl;
  Function()? onConnectionEstablished; // Callback to be executed after connection
  String? accessToken;

  SignalRService(this.hubUrl);

  Future<void> initializeConnection(String accessToken) async {
    this.accessToken = accessToken;
    if (isInitialized) {
      print('HubConnection is already initialized.');
      return;
    }
    hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, HttpConnectionOptions(
          accessTokenFactory: () async => accessToken,
        ))
        .build();

    isInitialized = true;

    hubConnection?.onclose((error) {
      signalRConnectionChange(false);
    });
  }

  Future<void> startConnection() async {
    try {
      if (hubConnection == null) {
        print('HubConnection is not initialized.');
        if(accessToken != null){
          await initializeConnection(accessToken!);
        }else{
          return;
        }
      }
      await hubConnection!.start();
      signalRConnectionChange(true);
      print('SignalR Connection Started');
      
      // Execute the callback after connection is established
      onConnectionEstablished?.call();
    } catch (e) {
      signalRConnectionChange(false);
      print('Error starting SignalR connection: $e');
    }
  }

  void signalRConnectionChange(bool connected) {
    isConnected = connected;
    print('SignalR Connected: $connected');
  }

  void registerOnTrackReady(Function(dynamic data) onTrackReady) {
    hubConnection?.on('TrackReady', (arguments) {
      TrackProcessed deserializedMessage = TrackProcessed.fromJson(arguments?[0]);
      onTrackReady(deserializedMessage);
      print('Track Ready!');
    });
  }

  void registerTrackUploadFailed(Function(dynamic data) onTrackUploadFailed) {
    hubConnection?.on('UploadFailed', (arguments) {
      TrackProcessingFailedMessage deserializedMessage = TrackProcessingFailedMessage.fromJson(arguments?[0]);
      onTrackUploadFailed(deserializedMessage);
      print('Track Upload Failed!');
    });
  }

  // Set a callback to be executed right after the connection is established
  void setOnConnectionEstablishedCallback(Function() callback) {
    onConnectionEstablished = callback;
  }

  Future<void> dispose() async {
    if (hubConnection != null) {
      await hubConnection!.stop();
    }
  }
}




// // signalr_service.dart
// import 'package:signalr_core/signalr_core.dart';

// class SignalRService {
//   late HubConnection hubConnection;
//   bool isConnected = false;

//   SignalRService(String hubUrl, String? accessToken) {
//     hubConnection = HubConnectionBuilder()
//         .withUrl(hubUrl,
//             HttpConnectionOptions(
//               accessTokenFactory: () async => accessToken ?? "",
//               // Other options as needed
//             ))
//         .build();
//     hubConnection.onclose((error) => isConnected = false);
//   }

//   Future<void> startConnection() async {
//     try {
//       await hubConnection.start();
//       signalRConnectionChange(true);
//       print('SignalR Connection Started');
//     } catch (e) {
//       signalRConnectionChange(false);
//       print('Error starting SignalR connection: $e');
//     }
//   }

//   void signalRConnectionChange(bool connected){
//     isConnected = connected;
//   }

//   void registerOnTrackReady(Function(dynamic data) onTrackReady) {
//     hubConnection.on('TrackReady', (arguments) {
//       onTrackReady(arguments?[0]);
//     });
//   }

//   Future<void> dispose() async {
//     await hubConnection.stop();
//   }
// }
