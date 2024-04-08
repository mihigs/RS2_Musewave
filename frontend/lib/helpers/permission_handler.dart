import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    final result = await Permission.storage.request();
    if (result.isGranted) {
      // Permission granted
      print("Storage permission granted");
    } else {
      // Handle permission denied
      print("Storage permission denied");
    }
  }
}
