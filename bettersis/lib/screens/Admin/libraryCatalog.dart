import 'package:flutter/material.dart';
import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:bettersis/modules/show_message.dart';

class LibraryCatalogPage extends StatefulWidget {
  final VoidCallback onLogout;

  const LibraryCatalogPage({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  _LibraryCatalogPageState createState() => _LibraryCatalogPageState();
}

class _LibraryCatalogPageState extends State<LibraryCatalogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bookNameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ShowMessage.error(context, 'Please fill all fields and select an image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a unique filename using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${_bookNameController.text}_$timestamp.jpg';
      
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Library/Books/$filename');
      
      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      // Create book data
      final bookData = {
        'title': _bookNameController.text,
        'author': _authorController.text,
        'edition': _editionController.text,
        'category': _categoryController.text,
        'imagePath': 'Library/Books/$filename',
        'imageUrl': imageUrl,
        'timestamp': timestamp,
      };

      // Store book data in Firestore
      await FirebaseFirestore.instance
          .collection('library_books')
          .add(bookData);

      ShowMessage.success(context, 'Book uploaded successfully');
      _clearForm();
    } catch (e) {
      ShowMessage.error(context, 'Error uploading book: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _clearForm() {
    _bookNameController.clear();
    _authorController.clear();
    _editionController.clear();
    _categoryController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme('admin');

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Library Catalogue',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _bookNameController,
                decoration: const InputDecoration(
                  labelText: 'Book Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter book name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter author name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _editionController,
                decoration: const InputDecoration(
                  labelText: 'Edition',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter edition' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter category' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Select Book Cover Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                Container(
                  height: 200,
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
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.all(16),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _authorController.dispose();
    _editionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
} 