import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';
import '../../shared/widgets/bottom_nav.dart';
import 'widgets/user_history_list.dart';
import 'widgets/global_stats_grid.dart';
import '../../routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthStorage.isLoggedIn();

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'app-logo',
          child: Image.asset('assets/images/whiteLogo.png', width: 48),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            const SizedBox(height: 24),

            const GlobalStatsGrid(),

            const SizedBox(height: 24),

            if (isLoggedIn) const UserHistoryList(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.upload);
        },
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),

      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
