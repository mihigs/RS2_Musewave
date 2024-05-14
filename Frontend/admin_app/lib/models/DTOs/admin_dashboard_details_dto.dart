class AdminDashboardDetailsDto {
  int musewaveTrackCount;
  int jamendoTrackCount;
  int userCount;
  int artistCount;
  int dailyLoginCount;
  int jamendoApiActivity;
  int totalTimeListened;

  AdminDashboardDetailsDto({
    required this.musewaveTrackCount,
    required this.jamendoTrackCount,
    required this.userCount,
    required this.artistCount,
    required this.dailyLoginCount,
    required this.jamendoApiActivity,
    required this.totalTimeListened,
  });

  // Converting a JSON map to the DTO instance
  factory AdminDashboardDetailsDto.fromJson(Map<String, dynamic> json) => AdminDashboardDetailsDto(
        musewaveTrackCount: json['musewaveTrackCount'],
        jamendoTrackCount: json['jamendoTrackCount'],
        userCount: json['userCount'],
        artistCount: json['artistCount'],
        dailyLoginCount: json['dailyLoginCount'],
        jamendoApiActivity: json['jamendoApiActivity'],
        totalTimeListened: json['totalTimeListened'],
      );

  // Converting the DTO instance to a JSON map
  Map<String, dynamic> toJson() => {
        'musewaveTrackCount': musewaveTrackCount,
        'jamendoTrackCount': jamendoTrackCount,
        'userCount': userCount,
        'artistCount': artistCount,
        'dailyLoginCount': dailyLoginCount,
        'jamendoApiActivity': jamendoApiActivity,
        'totalTimeListened': totalTimeListened,
      };
}
