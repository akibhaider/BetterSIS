import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appbarHeight;

  const CustomAppBar({super.key, required this.appbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(appbarHeight); 

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: null, 
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2196F3),    
              Colors.cyan,
              Colors.cyanAccent,
              Colors.white,   
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Background color for the border
              borderRadius: BorderRadius.circular(10), // Rounded corners
              border: Border.all(
                color: Colors.white, // Faint border color
                width: 3.5,         // Border width
              ),
            ),
            child: const Text(
              'BetterSIS',
              style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0, 
    );
  }
}
