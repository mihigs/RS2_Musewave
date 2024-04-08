import 'package:frontend/models/base/streaming_context.dart';

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input; // Return empty string if input is empty
  }
  String lowerCaseInput = input.toLowerCase();
  String result = lowerCaseInput.substring(0, 1).toUpperCase() + lowerCaseInput.substring(1);
  return result;
}

String formatDuration(int durationInSeconds) {
  int minutes = durationInSeconds ~/ 60;
  int seconds = durationInSeconds % 60;

  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = seconds.toString().padLeft(2, '0');

  return '$minutesStr:$secondsStr';
}

StreamingContextType getStreamingContextTypeFromString(String typeString) {
  if (typeString.toUpperCase() == 'RADIO' || typeString == "0") {
    return StreamingContextType.RADIO;
  } else if (typeString.toUpperCase() == 'ALBUM' || typeString == "1") {
    return StreamingContextType.ALBUM;
  } else if (typeString.toUpperCase() == 'PLAYLIST' || typeString == "2") {
    return StreamingContextType.PLAYLIST;
  } else if (typeString.toUpperCase() == 'JAMENDO' || typeString == "3") {
    return StreamingContextType.JAMENDO;
  } else if (typeString.toUpperCase() == 'LIKED' || typeString == "4") {
    return StreamingContextType.LIKED;
  } else if (typeString.toUpperCase() == 'WEEKLY' || typeString == "5") {
    return StreamingContextType.WEEKLY;
  } else {
    throw Exception('Unknown streaming context type: $typeString');
  }
}

String getStringFromStreamingContextType(StreamingContextType type) {
  switch (type) {
    case StreamingContextType.RADIO:
      return "RADIO";
    case StreamingContextType.ALBUM:
      return "ALBUM";
    case StreamingContextType.PLAYLIST:
      return "PLAYLIST";
    case StreamingContextType.JAMENDO:
      return "JAMENDO";
    case StreamingContextType.LIKED:
      return "LIKED";
    case StreamingContextType.WEEKLY:
      return "WEEKLY";
    default:
      throw Exception('Unknown streaming context type');
  }
}


