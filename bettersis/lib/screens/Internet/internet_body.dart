import 'package:bettersis/utils/themes.dart';
import 'package:flutter/material.dart';

class InternetBody extends StatefulWidget {
  final String userId;
  final String userDept;

  const InternetBody({super.key, required this.userId, required this.userDept});

  @override
  State<InternetBody> createState() => _InternetBodyState();
}

class _InternetBodyState extends State<InternetBody> {
  String totalUsage = "10,780";
  List<Map<String, String>> history = [
    {
      "location": "Library",
      "duration": "69",
    },
    {
      "location": "AB2",
      "duration": "112",
    },
    {
      "location": "CDS",
      "duration": "15",
    }
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = AppTheme.getTheme(widget.userDept);
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      color: theme.primaryColor,
      width: screenSize.width,
      height: screenSize.height,
      child: Column(
        children: [
          /*
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
            child: Text(
              'IUT INTERNET',
              style: TextStyle(
                fontSize: 0.032 * screenSize.width,
                fontWeight: FontWeight.w500,
                color: theme.secondaryHeaderColor,
              ),
            ),
          ),
          */
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26.0),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: const Column(
              children: [
                Text(
                  'FAHIM RAHMAN',
                  style: TextStyle(
                    fontSize: 27.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '210041205',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 0.083 * screenSize.width),
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.grey.withOpacity(0.5), // Shadow color with opacity
                  spreadRadius: 5, // How much the shadow spreads
                  blurRadius: 7, // How blurry the shadow is
                  offset: const Offset(0,
                      3), // The position of the shadow (horizontal, vertical)
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Minutes Used',
                  style: TextStyle(
                    fontSize: 0.037 * screenSize.width,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryHeaderColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalUsage,
                        style: TextStyle(
                          fontSize: 0.083 * screenSize.width,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryHeaderColor,
                        ),
                      ),
                      Text(
                        'out of',
                        style: TextStyle(
                          fontSize: 0.046 * screenSize.width,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryHeaderColor,
                        ),
                      ),
                      Text(
                        '12,000',
                        style: TextStyle(
                          fontSize: 0.083 * screenSize.width,
                          fontWeight: FontWeight.w700,
                          color: theme.secondaryHeaderColor,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 26, bottom: 16),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  Text(
                    "REFRESH",
                    style: TextStyle(
                      fontSize: 0.032 * screenSize.width,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  )
                ],
              )),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USAGE HISTORY',
                    style: TextStyle(
                        color: theme.secondaryHeaderColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.circle_rounded),
                            ),
                            title: Text(
                                'IUTWLAN - ${history[index]['location']!}'),
                            trailing: Text(
                              '${history[index]['duration']!} Mins',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View More >>',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
