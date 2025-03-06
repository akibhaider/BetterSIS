import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
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

  List<Map<String, dynamic>> storedUsers = [];

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
      final storagePath = '${idController.text.trim()}.png';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      await storageRef.putFile(_selectedImage!);
    }
  }

  // void generateEmail() {
  //   if (name != null && name!.isNotEmpty) {
  //     var parts = name!.split(" ");
  //     if (parts.length > 1) {
  //       email =
  //           "${parts[0].toLowerCase()}${parts[1].toLowerCase()}@iut-dhaka.edu";
  //     } else {
  //       email = "${parts[0].toLowerCase()}@iut-dhaka.edu";
  //     }
  //     setState(() {});
  //   }
  // }

   // Function to check and generate a unique email
  String checkAndGenerateEmail(String baseEmail) {
    int count = 1;
    String uniqueEmail = baseEmail;
    
    // Loop to find the first non-existing email
    while (storedUsers.any((user) => user['email'] == uniqueEmail)) {
      uniqueEmail = baseEmail.replaceFirst('@', '$count@');
      count++;
    }

    return uniqueEmail;
  }

  // Update generateEmail function to use the new checkAndGenerateEmail
  void generateEmail() {
    if (name != null && name!.isNotEmpty) {
      var parts = name!.split(" ");
      String baseEmail = parts.length > 1
          ? "${parts[0].toLowerCase()}${parts[1].toLowerCase()}@iut-dhaka.edu"
          : "${parts[0].toLowerCase()}@iut-dhaka.edu";
      
      email = checkAndGenerateEmail(baseEmail);  // Generate unique email
      setState(() {});
    }
  }

  Future<void> createAccountStudent() async {
    try {
      await uploadImage();
      String chosenSemester = semester.toString();

      await FirebaseFirestore.instance.collection('Users').add({
        'cr': isCR,
        'dept': department,
        'email': email,
        'id': idController.text.trim(),
        'name': name,
        'phone': phoneController.text.trim(),
        'program': program,
        'section': section,
        'semester': chosenSemester,
        'type': 'student',
      });
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

  Future<void> fetchExistingIds() async {
    try {
      QuerySnapshot userDoc =
          await FirebaseFirestore.instance.collection('Users').get();

      for (var users in userDoc.docs) {
        if (users['type'] == 'student') {
          storedUsers.add(users.data() as Map<String, dynamic>);
        }
      }

      for (var users in storedUsers) {
        print('\n\n\n ${users['id']} ---- ${users['email']} \n\n\n');
      }
    } catch (error) {
      print('\n\n Error fetching \n\n');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchExistingIds();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme('admin');
    var screenWidth = MediaQuery.of(context).size.width;
    var isTablet = screenWidth > 600; // Threshold for larger devices

    return Scaffold(
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Create Account',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              hint: Text("Choose Type"),
              items: ['Student'].map((type) {
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
                  onPressed: () async {
                    // Show the confirmation dialog
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Account Creation"),
                        content: Text("Are you sure you want to create the account with ID: ${idController.text.trim()}?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // No
                            },
                            child: Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Yes
                            },
                            child: Text("Yes"),
                          ),
                        ],
                      ),
                    );

                    // If confirmed, create the account
                    if (confirmed == true) {
                      await createAccountStudent();
                    } else {
                      // Show confirmation message if not confirmed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Account creation cancelled")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Create Account", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
