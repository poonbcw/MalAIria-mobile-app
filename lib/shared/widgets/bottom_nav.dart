import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';

import '../../features/dashboard/dashboard_page.dart'; 
import '../../features/profile/profile_page.dart';
import '../../features/auth/login_page.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  // --- ฟังก์ชันพระเอกที่ถูกอัปเกรด: คืนชีพ Hero ด้วย Fade Transition ---
  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300), // ✅ ให้เวลา Hero ทำงาน
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // ใช้ Fade Transition (ค่อยๆ ปรากฏ) เพื่อกลบเกลื่อน Slide ของระบบ
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  // 1. ไปหน้าหลัก (เคลียร์ประวัติทั้งหมดทิ้ง ป้องกันหน้าซ้อนกัน)
  void _goToDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _fadeRoute(const DashboardPage()), // ✅ ใช้ Fade Route
      (route) => false, 
    );
  }

  // 2. ไปหน้าอื่นๆ (เปิดซ้อนทับหน้าเดิม ทำให้กดปุ่ม Back กลับมาได้)
  void _goToTab(BuildContext context, Widget page) {
    Navigator.push(
      context,
      _fadeRoute(page), // ✅ ใช้ Fade Route
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoggedIn = AuthStorage.isLoggedIn(); 

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 8,
      color: isDark ? const Color.fromARGB(255, 37, 41, 55) : Colors.white,

      child: SizedBox(
        height: 68,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              isActive: currentIndex == 0,
              onTap: () {
                if (currentIndex != 0) {
                  _goToDashboard(context);
                }
              },
            ),

            const SizedBox(width: 48), // เว้นช่องให้ปุ่ม + ตรงกลาง

            _NavItem(
              icon: Icons.person_rounded,
              isActive: currentIndex == 2,
              onTap: () {
                if (currentIndex != 2) {
                  if (isLoggedIn) {
                    _goToTab(context, const ProfilePage());
                  } else {
                    _goToTab(context, const LoginPage());
                  }
                }
              },
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