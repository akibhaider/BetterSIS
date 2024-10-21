import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class GenerateAdmitCard extends StatefulWidget {
  final String userId;
  final String userName;
  final String userDept;
  final String programme;
  final String semester;
  final List<String> registeredCourses;

  GenerateAdmitCard({
    required this.userId,
    required this.userName,
    required this.userDept,
    required this.programme,
    required this.semester,
    required this.registeredCourses,
  });

  @override
  _GenerateAdmitCardState createState() => _GenerateAdmitCardState();
}

class _GenerateAdmitCardState extends State<GenerateAdmitCard> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _generateAndSavePDF();
  }

  Future<void> _generateAndSavePDF() async {
    final pdf = pw.Document();
    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/admit_card.pdf";

    // Generate the PDF content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Islamic University of Technology (IUT)',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Winter Semester 2023-2024 (Mid Examination)'),
              pw.SizedBox(height: 10),
              pw.Text('Admit Card', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Text('Student ID: ${widget.userId}'),
              pw.Text('Name: ${widget.userName}'),
              pw.Text('Department: ${widget.userDept}'),
              pw.Text('Programme: ${widget.programme}'),
              pw.Text('Semester: ${widget.semester}'),
              pw.SizedBox(height: 20),
              pw.Text('Registered Theory Courses:'),
              pw.Bullet(
                text: widget.registeredCourses.join('\n'),
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Penalty of Committing Offences:'),
              pw.Text(
                '1. Attempt to communicate with other examinee or examiners...',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Registrar', textAlign: pw.TextAlign.right),
            ],
          );
        },
      ),
    );

    // Save the PDF file to the temporary directory
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Update the state with the PDF file path
    setState(() {
      pdfPath = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admit Card'),
      ),
      body: pdfPath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: pdfPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
              onRender: (_pages) {
                setState(() {});
              },
              onError: (error) {
                print(error.toString());
              },
              onPageError: (page, error) {
                print('$page: ${error.toString()}');
              },
            ),
    );
  }
}
