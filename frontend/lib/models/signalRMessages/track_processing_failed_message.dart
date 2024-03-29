class TrackProcessingFailedMessage {
  final String message;

  TrackProcessingFailedMessage({required this.message});

  factory TrackProcessingFailedMessage.fromJson(Map<String, dynamic> json) {
    return TrackProcessingFailedMessage(
      message: json['message'],
    );
  }
}
