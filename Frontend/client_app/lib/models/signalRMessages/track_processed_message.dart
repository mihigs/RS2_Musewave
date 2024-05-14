class TrackProcessed {
  final String trackId;
  final String trackTitle;

  TrackProcessed({required this.trackId, required this.trackTitle});

  factory TrackProcessed.fromJson(Map<String, dynamic> json) {
    return TrackProcessed(
      trackId: json['trackId'],
      trackTitle: json['trackTitle'],
    );
  }
}
