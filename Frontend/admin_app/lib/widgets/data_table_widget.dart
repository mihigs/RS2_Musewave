import 'package:admin_app/models/report.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/utils/month_utils.dart';

class DataTableWidget extends StatefulWidget {
  final List<Report> reports;
  final Function(Report?) onReportSelected;

  DataTableWidget({required this.reports, required this.onReportSelected});

  @override
  _DataTableWidgetState createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  late List<Report> _reports;
  Report? _selectedReport;

  @override
  void initState() {
    super.initState();
    _reports = widget.reports;
  }

  void _sort<T>(
    Comparable<T> Function(Report report) getField,
    int columnIndex,
    bool ascending,
  ) {
    _reports.sort((Report a, Report b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      showCheckboxColumn: false,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn(
          label: Text('Report Date'),
          onSort: (int columnIndex, bool ascending) =>
              _sort<DateTime>((Report r) => r.reportDate, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Report Month/Year'),
          onSort: (int columnIndex, bool ascending) =>
              _sort<String>(
                (Report r) => '${r.reportYear}-${r.reportMonth}',
                columnIndex,
                ascending,
              ),
        ),
        DataColumn(
          label: Text('New Musewave Tracks'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.newMusewaveTrackCount, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('New Jamendo Tracks'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.newJamendoTrackCount, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('New Users'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.newUserCount, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('New Artists'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.newArtistCount, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Daily Logins'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.dailyLoginCount, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Monthly Jamendo API Activity'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.monthlyJamendoApiActivity, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Monthly Time Listened'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.monthlyTimeListened, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Monthly Donations Amount'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.monthlyDonationsAmount, columnIndex, ascending),
        ),
        DataColumn(
          label: Text('Monthly Donations Count'),
          numeric: true,
          onSort: (int columnIndex, bool ascending) =>
              _sort<num>((Report r) => r.monthlyDonationsCount, columnIndex, ascending),
        ),
      ],
      rows: _reports.asMap().entries.map((entry) {
        int index = entry.key;
        Report report = entry.value;
        final isSelected = report.id == _selectedReport?.id;

        return DataRow(
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (isSelected) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.2);
            }
            return null; // Use default value for other states and rows
          }),
          cells: [
            DataCell(
              Text(_formatDate(report.reportDate)),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${MonthUtils.getMonthName(report.reportMonth)}/${report.reportYear}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.newMusewaveTrackCount}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.newJamendoTrackCount}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.newUserCount}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.newArtistCount}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.dailyLoginCount}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.monthlyJamendoApiActivity}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.monthlyTimeListened}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('\$${report.monthlyDonationsAmount.toStringAsFixed(2)}'),
              onTap: () => _onRowTap(report),
            ),
            DataCell(
              Text('${report.monthlyDonationsCount}'),
              onTap: () => _onRowTap(report),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _onRowTap(Report report) {
    setState(() {
      if (_selectedReport == report) {
        _selectedReport = null;
      } else {
        _selectedReport = report;
      }
    });
    widget.onReportSelected(_selectedReport);
  }
}
