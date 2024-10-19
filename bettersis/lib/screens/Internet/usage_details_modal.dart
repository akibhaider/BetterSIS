import 'package:flutter/material.dart';

class UsageDetailsModal extends StatelessWidget {
  final Map<String, dynamic> usage;

  const UsageDetailsModal({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.6),
        body: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usage Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text('Location: ${usage['location'] ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Text('Start Time: ${usage['start'] ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Text('End Time: ${usage['end'] ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Text('Duration: ${usage['duration'] ?? 'N/A'}'),
                  const SizedBox(height: 10),
                  Text('Data Used: ${usage['mb'] ?? 'N/A'} MB'),
                  const SizedBox(height: 10),
                  Text('MAC Address: ${usage['mac'] ?? 'N/A'}'),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
