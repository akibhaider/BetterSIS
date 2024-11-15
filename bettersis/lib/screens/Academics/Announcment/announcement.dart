import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Announcement extends StatefulWidget {
  final bool isCr;
  final String userName;
  final String userId;
  final String userDept;
  final String userProgram;
  final String userSection;
  final String userSemester;
  final VoidCallback onLogout;

  const Announcement({
    super.key,
    required this.isCr,
    required this.userName,
    required this.userId,
    required this.userDept,
    required this.userProgram,
    required this.userSection,
    required this.userSemester,
    required this.onLogout,
  });

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  // Fetch announcements from Firestore
  Future<void> _fetchAnnouncements() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firestore path based on the new schema
      DocumentSnapshot docSnapshot = await _firestore
          .collection('Announcements')
          .doc(widget.userDept)
          .collection(widget.userProgram)
          .doc(widget.userSemester[0])
          .get();

      if (docSnapshot.exists) {
        List<dynamic> announcementData = docSnapshot[widget.userSection] ?? [];
        setState(() {
          announcements = List<Map<String, dynamic>>.from(announcementData);
        });
      }
    } catch (e) {
      print("Error fetching announcements: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  // Add a new announcement to Firestore
  Future<void> _addAnnouncement(String title, String message) async {
    String date = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    Map<String, String> newAnnouncement = {
      'title': title,
      'message': message,
      'author': widget.userName,
      'date': date,
    };

    try {
      DocumentReference announcementRef = _firestore
          .collection('Announcements')
          .doc(widget.userDept)
          .collection(widget.userProgram)
          .doc(widget.userSemester[0]);

      await announcementRef.update({
        widget.userSection: FieldValue.arrayUnion([newAnnouncement]),
      });

      _fetchAnnouncements(); 
    } catch (e) {
      print('Error adding announcement: $e');
    }
  }

  // Remove an announcement from Firestore
  Future<void> _removeAnnouncement(Map<String, dynamic> announcement) async {
    try {
      DocumentReference announcementRef = _firestore
          .collection('Announcements')
          .doc(widget.userDept)
          .collection(widget.userProgram)
          .doc(widget.userSemester[0]);

      await announcementRef.update({
        widget.userSection: FieldValue.arrayRemove([announcement]),
      });

      _fetchAnnouncements(); 
    } catch (e) {
      print('Error removing announcement: $e');
    }
  }

  // Show pop-up dialog to add a new announcement
  Future<void> _showAddAnnouncementDialog() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Announcement"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: "Message"),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    messageController.text.isNotEmpty) {
                  _addAnnouncement(
                    titleController.text,
                    messageController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Show announcement details in a pop-up dialog
  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text("By ${announcement['author']}"),
                const SizedBox(height: 5),
                Text(announcement['date']),
                const Divider(),
                Text(announcement['message']),
                if (widget.isCr) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white,),
                        label: const Text("Remove", style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          Navigator.pop(context);
                          _removeAnnouncement(announcement); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: BetterSISAppBar(
          onLogout: widget.onLogout, theme: theme, title: "Announcements"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return GestureDetector(
                  onTap: () => _showAnnouncementDetails(announcement),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement['title'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "By ${announcement['author']}",
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            announcement['date'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: widget.isCr
          ? FloatingActionButton(
              onPressed: _showAddAnnouncementDialog,
              child: const Icon(Icons.add, color: Colors.white,),
              backgroundColor: theme.primaryColor,
            )
          : null,
    );
  }
}
