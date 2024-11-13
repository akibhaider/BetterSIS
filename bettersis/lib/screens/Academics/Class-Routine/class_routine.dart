import 'dart:io' as io;
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/modules/loading_spinner.dart';
import 'package:bettersis/modules/show_message.dart';
import 'package:bettersis/screens/Academics/Class-Routine/image_fullview_modal.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/permission_helper.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ClassRoutine extends StatefulWidget {
  final String userId;
  final String userDept;
  final String userProgram;
  final String userSemester;
  final String userSection;
  final VoidCallback onLogout;

  const ClassRoutine({
    super.key,
    required this.userId,
    required this.userDept,
    required this.userProgram,
    required this.userSemester,
    required this.userSection,
    required this.onLogout,
  });

  @override
  State<ClassRoutine> createState() => _ClassRoutineState();
}

class _ClassRoutineState extends State<ClassRoutine> {
  bool isLoading = true;
  String? routineImageUrl;

  Future<void> fetchRoutineImageFromFirestore() async {
    setState(() {
      isLoading = true;
    });

    try {
      final routineRef = FirebaseStorage.instance.ref().child(
          'Class-Routine/${widget.userDept}/${widget.userSemester}/${widget.userProgram}/${widget.userSection}/class_routine.jpg');
      String? downloadUrl = await routineRef.getDownloadURL();

      setState(() {
        routineImageUrl = downloadUrl;
      });
    } catch (e) {
      ShowMessage.error(context, "Error fetching routine image: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> downloadRoutine(BuildContext context) async {
    if (routineImageUrl == null) return;

    try {
      bool hasPermission =
          await PermissionsHelper.requestStoragePermission(context);
      if (!hasPermission) {
        ShowMessage.error(context, 'Storage permission is required');
        return;
      }

      final response = await http.get(Uri.parse(routineImageUrl!));

      final baseDir = await getExternalStorageDirectory();
      if (baseDir != null) {
        final customPath = io.Directory(
            '${baseDir.parent.parent.parent.parent.path}/Download/BetterSIS');

        if (!await customPath.exists()) {
          await customPath.create(recursive: true);
        }

        String filePath = '${customPath.path}/class_routine.png';
        final file = io.File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        ShowMessage.success(context, 'Routine downloaded to: $filePath');
      } else {
        ShowMessage.error(context, 'Failed to access storage');
      }
    } catch (e) {
      ShowMessage.error(context, 'Failed to download routine');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRoutineImageFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double fontSizeLarge = 0.05 * screenWidth;
    final double fontSizeSmall = 0.04 * screenWidth;

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Class Routine',
      ),
      body: Stack(
        children: [
          Container(
            color: theme.primaryColor,
            width: screenWidth,
            height: screenHeight,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 26.0),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Column(
                    children: [
                      Text(
                        'BSc in ${widget.userProgram.toUpperCase()}',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Semester: ${widget.userSemester}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Section: ${widget.userSection}',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: screenWidth,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Class Routine',
                          style: TextStyle(
                            color: theme.secondaryHeaderColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        routineImageUrl != null
                            ? Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  border: Border.all(
                                      color: Colors.grey[600]!, width: 2.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => ImageFullviewModal(
                                          imageUrl: routineImageUrl!),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      routineImageUrl!,
                                      width: screenWidth * 0.80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                            : const Expanded(
                                child: Center(
                                  child: Text('No routine available'),
                                ),
                              ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: routineImageUrl != null
                              ? () => downloadRoutine(context)
                              : null,
                          icon: const Icon(Icons.download),
                          label: const Text('Download Routine'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) const LoadingSpinner(),
        ],
      ),
    );
  }
}
