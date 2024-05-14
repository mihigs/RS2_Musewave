import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    var result = await Permission.storage.request();
    if (!result.isGranted) {
      result = await Permission.audio.request();
      if (result.isGranted) {
        print("Storage permission granted");
        return;
      }
      print("Storage permission denied");
    }
  }
}
