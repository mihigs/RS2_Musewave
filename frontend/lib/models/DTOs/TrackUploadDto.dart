class TrackUploadDto {
  final String? albumId;
  final String trackName;
  final String userId;

  TrackUploadDto({
    this.albumId,
    required this.trackName,
    required this.userId,
  });

  factory TrackUploadDto.fromJson(Map<String, dynamic> json) {
    return TrackUploadDto(
      albumId: json['albumId'],
      trackName: json['trackName'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'trackName': trackName,
      'userId': userId,
    };
  }
}