import 'package:flutter/material.dart';
import 'info_box.dart';

class UsageDetailsModal extends StatelessWidget {
  final Map<String, dynamic> usage;
  final ThemeData theme;

  const UsageDetailsModal({
    super.key,
    required this.usage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final fontSizeLarge = screenWidth * 0.05;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.6),
        body: Center(
          child: GestureDetector(
            onTap: () {},
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Usage Details',
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InfoBox(
                            label: 'Location',
                            value: usage['location'],
                            theme: theme,
                          ),
                          InfoBox(
                            label: 'Duration',
                            value: usage['duration'],
                            theme: theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InfoBox(
                            label: 'Start Time',
                            value: usage['start'],
                            theme: theme,
                          ),
                          InfoBox(
                            label: 'End Time',
                            value: usage['end'],
                            theme: theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InfoBox(
                            label: 'Data Used',
                            value: usage['mb'],
                            theme: theme,
                          ),
                          InfoBox(
                            label: 'MAC Address',
                            value: usage['mac'],
                            theme: theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
