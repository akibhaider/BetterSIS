import 'package:flutter/material.dart';

class BetterSISAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
  final ThemeData theme;
  final String title;

  void _buttonPressed(){
    return;
  }

  const BetterSISAppBar({
    Key? key,
    required this.onLogout,
    required this.theme,
    required this.title
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: theme.primaryColor,
      automaticallyImplyLeading: false, 
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        tooltip: 'Menu',
        onPressed: _buttonPressed,
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            // 'BetterSIS' Title with rounded borders
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white),
              ),
              child: const Text(
                'BetterSIS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 'Dashboard' title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
