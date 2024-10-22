import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../utils/Utils.dart';

class GenerateAdmitCard extends StatefulWidget {
  final String userId;
  final String userName;
  final String userDept;
  final String programme;
  final String semester;
  final String examination;
  final List<String> registeredCourses;

  GenerateAdmitCard({
    required this.userId,
    required this.userName,
    required this.userDept,
    required this.programme,
    required this.semester,
    required this.examination,
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

    final iutLogo = pw.MemoryImage(
      (await rootBundle.load('assets/iut_logo.png')).buffer.asUint8List(),
    );
    final oicLogo = pw.MemoryImage(
      (await rootBundle.load('assets/oic_logo.jpg')).buffer.asUint8List(),
    );

    // final userImageUrl = Utils.getUserImageURL();
    // final userImageBytes = await _fetchImageFromUrl(userImageUrl);

    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/admit_card.pdf";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(iutLogo, width: 60), // Left IUT logo
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Islamic University of Technology (IUT)',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        '(A Subsidiary Organ of the OIC)',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Image(oicLogo, width: 60), 
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '${widget.semester} Semester 2023-2024 (${widget.examination} Examination)',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Admit Card',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Student ID: ${widget.userId}',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Name: ${widget.userName}',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Department: ${widget.userDept}',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Programme: ${widget.programme}',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Semester: ${widget.semester}',
                          style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Image(iutLogo, width: 60), 
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Registered Theory Courses:',
                  style: pw.TextStyle(fontSize: 12)),
              pw.Bullet(
                text: widget.registeredCourses.join('\n'),
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'PENALTY OF COMMITTING OFFENCES RELATED TO EXAMINATIONS (GERR ARTICLE 8.0)',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '''1. Attempt to communicate with other examinee or examiners:
   a. First time – Warning by the invigilator.
   b. Second time – Changing of seats by the invigilator.
   c. Third time – Expulsion from the examination hall for that paper by the Chief Invigilator.
2. Possession of incriminating documents or possession of writings related to the subject of examination...''',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Registrar', style: pw.TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    setState(() {
      pdfPath = filePath;
    });
  }

  Future<Uint8List> _fetchImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image from $imageUrl');
    }
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
