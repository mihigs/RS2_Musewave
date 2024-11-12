class ReportsQuery {
  DateTime? startDate;
  DateTime? endDate;
  int? month;
  int? year;

  ReportsQuery({this.startDate, this.endDate, this.month, this.year});

  List<String> toQueryParameters() {
    List<String> queryParams = [];

    if (startDate != null) queryParams.add('?startDate=${startDate!.toIso8601String()}');
    if (endDate != null) queryParams.add('?endDate=${endDate!.toIso8601String()}');
    if (month != null) queryParams.add('?month=$month');
    if (year != null) queryParams.add('?year=$year');

    return queryParams;
  }

  bool hasFilters() {
    return startDate != null || endDate != null || month != null || year != null;
  }
}
