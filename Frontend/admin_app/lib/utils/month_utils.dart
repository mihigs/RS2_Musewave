class MonthUtils {
  static final List<String> monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ];

  static String getMonthName(int monthNumber) {
    if (monthNumber >= 1 && monthNumber <= 12) {
      return monthNames[monthNumber - 1];
    } else {
      return 'Unknown';
    }
  }
}
