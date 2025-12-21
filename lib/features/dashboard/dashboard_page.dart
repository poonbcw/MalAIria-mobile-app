import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';
import '../../shared/widgets/bottom_nav.dart';
import 'widgets/global_stats_card.dart';
import 'widgets/user_history_list.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthStorage.isLoggedIn();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔵 HERO LOGO (ต่อจาก Splash)
          Center(
            child: Hero(
              tag: 'app-logo',
              child: Image.asset(
                'assets/images/whiteLogo.png',
                width: 80,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 📊 GLOBAL STATISTICS
          const GlobalStatsCard(),

          const SizedBox(height: 24),

          // 👤 USER HISTORY (เฉพาะคนที่ login)
          if (isLoggedIn) const UserHistoryList(),
        ],
      ),
    );
  }
}
