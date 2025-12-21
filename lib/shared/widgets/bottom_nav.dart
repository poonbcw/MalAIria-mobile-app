import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (index == 1) {
          Navigator.pushNamed(context, AppRoutes.upload);
        } else {
          Navigator.pushNamed(context, AppRoutes.login);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Detect'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Login'),
      ],
    );
  }
}
