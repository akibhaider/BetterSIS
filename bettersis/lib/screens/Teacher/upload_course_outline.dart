import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:bettersis/modules/show_message.dart';

class UploadCourseOutlinePage extends StatefulWidget {
  final String userDept;
  final VoidCallback onLogout;

  const UploadCourseOutlinePage({
    Key? key,
    required this.userDept,
    required this.onLogout,
  }) : super(key: key);

  @override
  _UploadCourseOutlinePageState createState() => _UploadCourseOutlinePageState();
}

class _UploadCourseOutlinePageState extends State<UploadCourseOutlinePage> {
  String? _selectedCourse;
  File? _selectedImage;
  bool _isUploading = false;
  String? _existingOutlineUrl;

  final List<String> courses = ['CSE 4501', 'CSE 4503', 'CSE 4511', 'CSE 4513'];

  void _resetForm() {
    setState(() {
      _selectedCourse = null;
      _selectedImage = null;
      _existingOutlineUrl = null;
    });
  }

  Future<void> _checkExistingOutline() async {
    if (_selectedCourse == null) return;

    try {
      final storagePath = 'Library/course_outlines/${_selectedCourse}/outline.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      final url = await storageRef.getDownloadURL();
      setState(() {
        _existingOutlineUrl = url;
      });
    } catch (e) {
      setState(() {
        _existingOutlineUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_selectedCourse == null) {
      ShowMessage.error(context, 'Please select a course first');
      return;
    }

    if (_existingOutlineUrl != null) {
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('A file already exists. Do you want to overwrite it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Overwrite'),
            ),
          ],
        ),
      );

      if (shouldOverwrite != true) return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadOutline() async {
    if (_selectedCourse == null || _selectedImage == null) {
      ShowMessage.error(context, 'Please select both course and image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final storagePath = 'Library/course_outlines/${_selectedCourse}/outline.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      
      await storageRef.putFile(_selectedImage!);

      ShowMessage.success(context, 'File uploaded successfully');
      Navigator.pop(context);
    } catch (e) {
      print('Error uploading File: $e');
      ShowMessage.error(context, 'Error uploading File');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Upload File',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reset Button
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

            // Course Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
              ),
              value: _selectedCourse,
              items: courses.map((course) {
                return DropdownMenuItem(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
                _checkExistingOutline();
              },
            ),
            const SizedBox(height: 24),

            // Existing Outline Preview
            if (_existingOutlineUrl != null) ...[
              const Text(
                'Current File:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.network(
                  _existingOutlineUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Select Image Button
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select a File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
            ),

            // New Image Preview
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              const Text(
                'New File:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Upload Button
            ElevatedButton(
              onPressed: _isUploading || _selectedImage == null ? null : _uploadOutline,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.all(16),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload File'),
            ),
          ],
        ),
      ),
    );
  }
} 