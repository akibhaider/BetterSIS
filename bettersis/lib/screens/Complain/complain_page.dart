import 'package:bettersis/modules/bettersis_appbar.dart';
import 'package:bettersis/screens/Misc/appdrawer.dart';
import 'package:bettersis/utils/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ComplainPage extends StatefulWidget {
  final VoidCallback onLogout;
  final String userId;
  final String userDept;

  const ComplainPage(
      {super.key,
      required this.onLogout,
      required this.userId,
      required this.userDept});

  @override
  State<ComplainPage> createState() => _ComplainPageState();
}

class _ComplainPageState extends State<ComplainPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  String? _selectedIssue;
  bool _showSubjectField = false;

  final List<String> _issues = [
    'Login Issues',
    'Payment Problems',
    'UI',
    'Performance',
    'Others'
  ];

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    final issue = _issueController.text.trim();
    final subject =
        _showSubjectField ? _subjectController.text.trim() : _selectedIssue;

    if (issue.isEmpty || subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      DocumentReference subjectRef = _showSubjectField
          ? FirebaseFirestore.instance.collection('Complains').doc('Others')
          : FirebaseFirestore.instance.collection('Complains').doc(subject);

      final subjectDoc = await subjectRef.get();
      if (!subjectDoc.exists) {
        throw Exception('Subject document not found');
      }

      final data = subjectDoc.data() as Map<String, dynamic>;

      int currentComplains = data['complains'] ?? 0;
      int currentUsers = data['users'] ?? 0;

      CollectionReference userComplaints = subjectRef.collection(widget.userId);

      final userComplaintsSnapshot = await userComplaints.get();

      await subjectRef.update({
        'complains': currentComplains + 1,
      });

      if (userComplaintsSnapshot.docs.isEmpty) {
        await subjectRef.update({
          'users': currentUsers + 1,
        });
      }

      final complaintDoc = userComplaints.doc(); 
      final complaintData = {
        if (_showSubjectField)
          'subject': subject, 
        'issue': issue,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await complaintDoc.set(complaintData);

      _issueController.clear();
      _subjectController.clear();
      setState(() {
        _selectedIssue = null;
        _showSubjectField = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting complaint: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);

    return Scaffold(
      drawer: CustomAppDrawer(theme: theme),
      appBar: BetterSISAppBar(
        onLogout: widget.onLogout,
        theme: theme,
        title: 'Complain',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Facing problems? Let us know',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select an Issue',
                  border: OutlineInputBorder(),
                ),
                value: _selectedIssue,
                items: _issues.map((String issue) {
                  return DropdownMenuItem<String>(
                    value: issue,
                    child: Text(issue),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIssue = value;
                    _showSubjectField = value == 'Others';
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an issue' : null,
              ),
              const SizedBox(height: 20),
              if (_showSubjectField)
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a subject'
                      : null,
                ),
              if (_showSubjectField) const SizedBox(height: 20),
              TextFormField(
                controller: _issueController,
                decoration: const InputDecoration(
                  labelText: 'Describe the problem',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please describe the issue'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitComplaint,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _issueController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
