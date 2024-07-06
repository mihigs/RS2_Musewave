class AdminDashboardDetailsDto {
  int musewaveTrackCount;
  int jamendoTrackCount;
  int userCount;
  int artistCount;
  int dailyLoginCount;
  int jamendoApiActivity;
  int totalTimeListened;
  double totalDonationsAmount;
  int totalDonationsCount;

  AdminDashboardDetailsDto({
    required this.musewaveTrackCount,
    required this.jamendoTrackCount,
    required this.userCount,
    required this.artistCount,
    required this.dailyLoginCount,
    required this.jamendoApiActivity,
    required this.totalTimeListened,
    required this.totalDonationsAmount,
    required this.totalDonationsCount,
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
        totalDonationsAmount: json['totalDonationsAmount'].toDouble(),
        totalDonationsCount: json['totalDonationsCount'],
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
        'totalDonationsAmount': totalDonationsAmount,
        'totalDonationsCount': totalDonationsCount,
      };
}
