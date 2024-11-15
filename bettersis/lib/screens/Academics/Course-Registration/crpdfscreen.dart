import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/modules/show_message.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/permission_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../../modules/Course Registration/courseregpdf.dart'; // Import the PDF generator file
import 'dart:io' as io;
import 'package:bettersis/utils/themes.dart';

class crpdfScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> courses;
  final VoidCallback onLogout; // List of courses

  const crpdfScreen({super.key, 
    required this.userData,
    required this.courses,
    required this.onLogout,
  });

  @override
  _CourseRegistrationScreenState createState() => _CourseRegistrationScreenState();
}

class _CourseRegistrationScreenState extends State<crpdfScreen> {
  String? pdfFilePath;
  String academicYear = '2023 - 2024';

  @override
  void initState() {
    super.initState();
    _generateAndDisplayPDF();
  }

  Future<void> _generateAndDisplayPDF() async {
    // Create the PDF generator with all required data
    final pdfGenerator = CourseRegistrationPDF(
      studentId: widget.userData['id'],
      name: widget.userData['name'],
      program: widget.userData['program'],
      department: widget.userData['dept'],
      academicYear: academicYear,
      semester: widget.userData['semester'],
      courses: widget.courses,
    );

    // Generate the PDF and store the file path
    final filePath = await pdfGenerator.generatePDF();
    setState(() {
      pdfFilePath = filePath;
    });
  }

  Future<void> _downloadPDF() async {
    // Print statement for now; implement actual download functionality later
    print("Download clicked");

    try{
      bool hasPermission =
          await PermissionsHelper.requestStoragePermission(context);
      if (!hasPermission) {
        ShowMessage.error(context, 'Storage permission is required');
        return;
      }

      if (pdfFilePath == null) {
        ShowMessage.error(context, 'PDF is not yet generated');
        return;
      }

      final baseDir = await getExternalStorageDirectory();
      if (baseDir != null) {
        final customPath = io.Directory(
            '${baseDir.parent.parent.parent.parent.path}/Download/BetterSIS');

        if (!await customPath.exists()) {
          await customPath.create(recursive: true);
        }

        String filePath =
            '${customPath.path}/course_registration: ${widget.userData['program']}_${widget.userData['semester']}.pdf';
        final file = io.File(pdfFilePath!);

        await file.copy(filePath);
        ShowMessage.success(context, 'Course Registration downloaded to: $filePath');
      } else {
        ShowMessage.error(context, 'Failed to access storage');
      }
    } catch (error) {
      ShowMessage.error(context, 'Failed to download Course Registration form');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userData['dept']);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Enrolled Courses',
      ),
      body: pdfFilePath == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Greyish container to display PDF with a border
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 158, 158, 158),
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PDFView(
                      filePath: pdfFilePath,
                      autoSpacing: false,
                      swipeHorizontal: true,
                      pageSnap: true,
                      fitEachPage: true,
                      fitPolicy: FitPolicy.BOTH,
                    ),
                  ),
                ),
                // Download button at the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _downloadPDF,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text('Download File',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}