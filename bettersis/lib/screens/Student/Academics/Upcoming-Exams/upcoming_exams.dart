import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:bettersis/modules/show_message.dart';

class UpcomingExams extends StatefulWidget {
  final String userId;
  final String userDept;
  final VoidCallback onLogout;

  const UpcomingExams({
    super.key,
    required this.userId,
    required this.userDept,
    required this.onLogout,
  });

  @override
  State<UpcomingExams> createState() => _UpcomingExamsState();
}

class _UpcomingExamsState extends State<UpcomingExams> {
  String? _selectedYear;
  String? _selectedSemester;
  String? _selectedExam;
  String? _seatPlanUrl;
  bool _isLoading = false;

  // Static options
  final List<String> academicYears = [
    '2020-21', '2021-22', '2022-23', '2023-24', '2024-25',
    '2025-26', '2026-27', '2027-28', '2028-29', '2029-30'
  ];
  final List<String> semesters = ['winter', 'summer'];
  final List<String> exams = ['mid', 'final'];

  void _resetForm() {
    setState(() {
      _selectedYear = null;
      _selectedSemester = null;
      _selectedExam = null;
      _seatPlanUrl = null;
    });
  }

  Future<void> _loadSeatPlan() async {
    if (_selectedYear == null || 
        _selectedSemester == null || 
        _selectedExam == null) return;

    setState(() => _isLoading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('ExamSeatPlan/${_selectedYear}/${_selectedSemester}/${_selectedExam}/seat_plan.jpg');
      
      final url = await ref.getDownloadURL();
      setState(() {
        _seatPlanUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading seat plan: $e');
      setState(() {
        _seatPlanUrl = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadSeatPlan() async {
    if (_seatPlanUrl == null) return;

    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ShowMessage.error(context, 'Storage permission is required to download files');
        return;
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ShowMessage.error(context, 'Failed to access storage');
        return;
      }

      final customPath = Directory(
          '${directory.parent.parent.parent.parent.path}/Download/BetterSIS/SeatPlans');

      if (!await customPath.exists()) {
        await customPath.create(recursive: true);
      }

      final filePath = '${customPath.path}/seat_plan_${_selectedYear}_${_selectedSemester}_${_selectedExam}.jpg';

      final response = await http.get(Uri.parse(_seatPlanUrl!));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      ShowMessage.success(context, 'Seat plan downloaded to Downloads/BetterSIS/SeatPlans');
    } catch (e) {
      print('Error downloading seat plan: $e');
      ShowMessage.error(context, 'Failed to download seat plan');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Upcoming Exams',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Form'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Academic Year Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                border: OutlineInputBorder(),
              ),
              value: _selectedYear,
              items: academicYears.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                  _selectedSemester = null;
                  _selectedExam = null;
                  _seatPlanUrl = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Semester Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
              value: _selectedSemester,
              items: semesters.map((semester) {
                return DropdownMenuItem(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: _selectedYear == null ? null : (value) {
                setState(() {
                  _selectedSemester = value;
                  _selectedExam = null;
                  _seatPlanUrl = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Exam Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Exam',
                border: OutlineInputBorder(),
              ),
              value: _selectedExam,
              items: exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam.toUpperCase()),
                );
              }).toList(),
              onChanged: _selectedSemester == null ? null : (value) {
                setState(() {
                  _selectedExam = value;
                });
                _loadSeatPlan();
              },
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_selectedYear != null && 
                     _selectedSemester != null && 
                     _selectedExam != null) ...[
              if (_seatPlanUrl != null) ...[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Image.network(
                    _seatPlanUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Error loading image'));
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _downloadSeatPlan,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Seat Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Seat plan not uploaded yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
