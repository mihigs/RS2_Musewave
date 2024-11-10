import 'package:flutter/foundation.dart';

class RefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners(); // Notifies listeners to refresh data
  }
}
