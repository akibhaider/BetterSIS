import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // For image manipulation
import '../../../modules/bettersis_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AccountCreator extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onLogout;

  const AccountCreator({
    super.key,
    required this.userData,
    required this.onLogout,
  });

  @override
  State<AccountCreator> createState() => _AccountCreatorState();
}

class _AccountCreatorState extends State<AccountCreator> {
  String? userType;
  String? name;
  String? department;
  String? program;
  String? phone;
  String? section;
  bool isCR = false;
  int? semester;
  String? id;
  String email = "";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  final departments = ['MPE', 'EEE', 'CEE', 'CSE', 'BTM'];
  final programs = ['MPE', 'EEE', 'CEE', 'CSE', 'SWE', 'IPE', 'BTM'];
  final sections = {
    'MPE': ['1', '2'],
    'EEE': ['1', '2', '3'],
    'CEE': ['1', '2'],
    'CSE': ['1', '2'],
    'BTM': ['1'],
    'SWE': ['1'],
    'IPE': ['1'],
  };

  final Map<int, String> semesterPrefixes = {
    1: '23',
    2: '23',
    3: '22',
    4: '22',
    5: '21',
    6: '21',
    7: '20',
    8: '20'
  };

  final Map<String, String> programPrefixes = {
    'MPE': '1',
    'SWE': '5',
    'EEE': '2',
    'IPE': '6',
    'CEE': '3',
    'BTM': '7',
    'CSE': '4'
  };

  File? _selectedImage;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Load image and check if it's a PNG
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      if (image == null ||
          pickedFile.path.split('.').last.toLowerCase() != 'png') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a valid PNG image")),
        );
        return;
      }

      // Resize the image to 300x300 pixels
      img.Image resizedImage = img.copyResize(image, width: 300, height: 300);

      // Save the resized image to a temporary file
      final resizedFile =
          await imageFile.writeAsBytes(img.encodePng(resizedImage));

      setState(() {
        _selectedImage = resizedFile;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImage != null) {
      final storagePath = '${id}.png';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      await storageRef.putFile(_selectedImage!);
    }
  }

  void generateEmail() {
    if (name != null && name!.isNotEmpty) {
      var parts = name!.split(" ");
      if (parts.length > 1) {
        email =
            "${parts[0].toLowerCase()}${parts[1].toLowerCase()}@iut-dhaka.edu";
      } else {
        email = "${parts[0].toLowerCase()}@iut-dhaka.edu";
      }
      setState(() {});
    }
  }

  Future<void> createAccount() async {
    try {
      await uploadImage();
      // Add the account creation logic here (e.g., saving data to Firestore)
    } catch (error) {
      print('Error creating account: $error');
    }
  }

  void updateIdFormat() {
    if (semester != null && program != null && section != null) {
      String semPrefix = semesterPrefixes[semester!] ?? 'XX';
      String programCode = (programs.indexOf(program!) + 1).toString();
      id = "${semPrefix}00${programCode}1${section}XX";
      setState(() {});
    }
  }

  Future<List<String>> fetchExistingIds() async {
    // Fetch the list of existing IDs from Firestore or any backend service
    // This function should be implemented once the backend is available
    return [];
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme('admin');

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Create Account',
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              hint: Text("Choose Type"),
              items: ['Student', 'Teacher'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  userType = value as String;
                });
              },
            ),
            if (userType == "Student") ...[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) {
                  name = value;
                  generateEmail();
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      hint: Text("Department"),
                      items: departments.map((dept) {
                        return DropdownMenuItem(value: dept, child: Text(dept));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          department = value as String;
                          updateIdFormat();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      hint: Text("Program"),
                      items: programs.map((prog) {
                        return DropdownMenuItem(value: prog, child: Text(prog));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          program = value as String;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      hint: Text("Semester"),
                      items: List.generate(8, (index) {
                        return DropdownMenuItem(
                            value: index + 1, child: Text("${index + 1}"));
                      }),
                      onChanged: (value) {
                        setState(() {
                          semester = value as int;
                          updateIdFormat();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField(
                      hint: Text("Section"),
                      items: department != null
                          ? sections[department]!.map((sec) {
                              return DropdownMenuItem(
                                  value: sec, child: Text(sec));
                            }).toList()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          section = value as String;
                          updateIdFormat();
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idController,
                      decoration: InputDecoration(labelText: "ID"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(id ?? "Format: XXXX")
                ],
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Email: $email",
                  style: TextStyle(fontSize: 16, color: theme.primaryColor),
                ),
              ),
              Row(
                children: [
                  Text("CR: "),
                  Switch(
                    value: isCR,
                    onChanged: (value) {
                      setState(() {
                        isCR = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    _selectedImage != null
                        ? Image.file(_selectedImage!, height: 100)
                        : Text("No image selected"),
                    ElevatedButton(
                      onPressed: pickImage,
                      child: Text("Select Image"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    createAccount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Create Account",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
