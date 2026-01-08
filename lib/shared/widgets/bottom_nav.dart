import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 8,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,

      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              isActive: currentIndex == 0,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.dashboard,
              ),
            ),

            const SizedBox(width: 48), // เว้นช่อง FAB

            _NavItem(
              icon: Icons.person_rounded,
              isActive: currentIndex == 2,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.login,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : const Color(0xFF2196F3);
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.4)
        : const Color(0xFFBDBDBD);

    return IconButton(
      icon: Icon(icon),
      iconSize: 26,
      color: isActive ? activeColor : inactiveColor,
      onPressed: onTap,
    );
  }
}
