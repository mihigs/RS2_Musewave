String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input; // Return empty string if input is empty
  }
  return input.substring(0, 1).toUpperCase() + input.substring(1);
}

  String formatDuration(int durationInSeconds) {
    int minutes = durationInSeconds ~/ 60;
    int seconds = durationInSeconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
