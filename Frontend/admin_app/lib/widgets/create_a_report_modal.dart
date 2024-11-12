import 'package:admin_app/services/admin_service.dart';
import 'package:admin_app/utils/month_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CreateAReportModal extends StatefulWidget {
  final VoidCallback onReportCreated;

  CreateAReportModal({required this.onReportCreated});

  @override
  _CreateAReportModalState createState() => _CreateAReportModalState();
}

class _CreateAReportModalState extends State<CreateAReportModal> {
  int? _selectedYear;
  int? _selectedMonth;

  bool _isLoading = false;

  final List<int> _years = List.generate(5, (index) => DateTime.now().year - index);
  final List<int> _months = List.generate(12, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create a Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        child: Text('Submit'),
                        onPressed: _submitReport,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _submitReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await GetIt.I<AdminService>().GenerateReport(month: _selectedMonth, year: _selectedYear);

      if (success) {
        // Close the modal
        Navigator.of(context).pop();

        // Notify the parent to refresh the reports
        widget.onReportCreated();
      }
    } catch (e) {
      // Handle error
      print('Error generating report: $e');
      // Optionally show a snackbar or dialog with error message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
