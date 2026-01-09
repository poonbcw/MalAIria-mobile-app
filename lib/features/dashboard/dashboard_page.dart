import 'package:flutter/material.dart';
import '../../shared/widgets/bottom_nav.dart';
import 'widgets/user_history_list.dart';
import 'widgets/global_stats_grid.dart';
import '../../routes/app_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'app-logo',
          child: Image.asset(
            'assets/images/whiteLogo.png',
            width: 48,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            const GlobalStatsGrid(),

            const SizedBox(height: 32),

            // ⚠️ อย่า pass isLoggedIn แล้ว
            const UserHistoryList(),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.white,
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.upload);
          setState(() {}); // 🔥 รีเฟรชหลังกลับมา
        },
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
