import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatelessWidget {
  final String documentUrl;
  final String screenTitle;

  const PDFViewerScreen({Key? key, required this.documentUrl, required this.screenTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle),
      ),
      body: SfPdfViewer.network(documentUrl),
    );
  }
}
