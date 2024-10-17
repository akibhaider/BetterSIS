import 'package:bettersis/modules/Notice/pdf_viewer_page.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:bettersis/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../modules/bettersis_appbar.dart';

class NoticeBoard extends StatefulWidget {
  const NoticeBoard({super.key});

  @override
  State<NoticeBoard> createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  bool isLoading = true;
  List<Map<String, dynamic>> noticeList = [];
  late String currentMonthYear;

  @override
  void initState() {
    super.initState();
    _initializeMonthYear();
    _fetchNotices();
  }

  void _initializeMonthYear() {
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    String monthName = Utils.getMonth(currentMonth);
    currentMonthYear = "$monthName, $currentYear"; 
  }

  Future<void> _fetchNotices() async {
    try {
      int currentYear = DateTime.now().year;
      int currentMonth = DateTime.now().month;

      CollectionReference noticesRef = FirebaseFirestore.instance
          .collection('Notices')
          .doc(currentYear.toString())
          .collection(currentMonth.toString());

      QuerySnapshot noticesSnapshot = await noticesRef.get();

      List<Map<String, dynamic>> tempNoticeList = [];

      for (var doc in noticesSnapshot.docs) {
        List<dynamic> noticeTitles = doc['notices'];

        for (var title in noticeTitles) {
          String fileName = '$title.pdf';
          String downloadLink = await _fetchDownloadLink(
              currentYear.toString(), currentMonth.toString(), fileName);
          tempNoticeList.add({
            'title': title,
            'link': downloadLink,
          });
        }
      }

      setState(() {
        noticeList = tempNoticeList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching notices: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _fetchDownloadLink(
      String year, String month, String fileName) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('Notices/$year/$month/$fileName');
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error fetching download link: $e');
    }
  }

  void _openPDFInApp(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(pdfUrl: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(Utils.getUser()['dept']);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: Utils.getLogout(),
        theme: theme,
        title: 'Notice Board',
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            child: Center(
              child: Text(
                currentMonthYear,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : noticeList.isEmpty
                  ? const Center(child: Text('No notices available'))
                  : Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: ListView.builder(
                          itemCount: noticeList.length,
                          itemBuilder: (context, index) {
                            final notice = noticeList[index];
                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01),
                              child: ListTile(
                                title: Text(
                                  notice['title'],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                    'Tap to view/download the notice'),
                                trailing: Icon(Icons.picture_as_pdf,
                                    color: theme.primaryColor),
                                onTap: () => _openPDFInApp(
                                    notice['link'], notice['title']),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}