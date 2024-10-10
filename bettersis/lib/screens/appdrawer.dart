import 'package:flutter/material.dart';

class CustomAppDrawer extends StatelessWidget {
  final ThemeData theme;

  const CustomAppDrawer({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.secondaryHeaderColor,
                  theme.primaryColor
                ]
              )
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Notice Board'),
            onTap: () {
              Navigator.of(context).pop(); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
      ),
    );
  }
}
