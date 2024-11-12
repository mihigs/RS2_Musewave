import 'package:admin_app/models/DTOs/reports_query.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/utils/month_utils.dart';

class ReportFilterModal extends StatefulWidget {
  final ReportsQuery initialQuery;
  final void Function(ReportsQuery query) onFilterApplied;

  ReportFilterModal({required this.initialQuery, required this.onFilterApplied});

  @override
  _ReportFilterModalState createState() => _ReportFilterModalState();
}

class _ReportFilterModalState extends State<ReportFilterModal> {
  int? _selectedMonth;
  int? _selectedYear;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final List<int> _years = List.generate(5, (index) => DateTime.now().year - index);
  final List<int> _months = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialQuery.month;
    _selectedYear = widget.initialQuery.year;
    _selectedStartDate = widget.initialQuery.startDate;
    _selectedEndDate = widget.initialQuery.endDate;
  }

  String _formatDateOnly(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: InputDecoration(
                labelText: 'Select Year',
                border: OutlineInputBorder(),
              ),
              items: _years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text('$year'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
              isExpanded: true,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: InputDecoration(
                labelText: 'Select Month',
                border: OutlineInputBorder(),
              ),
              items: _months.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(MonthUtils.getMonthName(month)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
              isExpanded: true,
            ),
            SizedBox(height: 10),
            // Start Date Picker
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedStartDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null)
                  setState(() {
                    _selectedStartDate = picked;
                  });
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Select Start Date',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(
                    text: _selectedStartDate != null ? _formatDateOnly(_selectedStartDate!) : '',
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // End Date Picker
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedEndDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null)
                  setState(() {
                    _selectedEndDate = picked;
                  });
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Select End Date',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(
                    text: _selectedEndDate != null ? _formatDateOnly(_selectedEndDate!) : '',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Clear Button
                  TextButton(
                    child: Text('Clear'),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = null;
                        _selectedYear = null;
                        _selectedStartDate = null;
                        _selectedEndDate = null;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    child: Text('Submit'),
                    onPressed: () {
                      ReportsQuery newQuery = ReportsQuery(
                        month: _selectedMonth,
                        year: _selectedYear,
                        startDate: _selectedStartDate,
                        endDate: _selectedEndDate,
                      );
                      widget.onFilterApplied(newQuery);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
