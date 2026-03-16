import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/storage/auth_storage.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- ฟังก์ชันสำหรับ Logout ---
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await AuthStorage.logout();
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      }
    } catch (e) {
      print("❌ Logout Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final media = MediaQuery.of(context);
    final height = media.size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 27, 50),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
            color: Colors.white,
          ),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'User not found.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: height * 0.04),
                  
                  // --- 1. รูปโปรไฟล์ (มีกรอบเรืองแสงนิดๆ) ---
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.15), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        image: user.photoURL != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(user.photoURL!),
                              )
                            : null,
                      ),
                      child: user.photoURL == null
                          ? Icon(Icons.person_rounded, size: 60, color: Colors.white.withOpacity(0.5))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 2. ชื่อและสถานะ ---
                  Text(
                    user.displayName ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  

                  const SizedBox(height: 48),

                  // --- 3. การ์ดข้อมูลส่วนตัว ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ACCOUNT DETAILS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.email_outlined, 'Email Address', user.email ?? 'No email'),
                        
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // --- 4. ปุ่ม LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3B30).withOpacity(0.1),
                        foregroundColor: const Color(0xFFFF3B30),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout_rounded, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'SIGN OUT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60), // เว้นที่ให้ BottomNav ด้านล่าง
                ],
              ),
            ),

      // --- Bottom Navigation ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.white, 
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.upload);
        },
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 2), 
    );
  }

  // Widget ช่วยวาดแถวข้อมูล (Icon + Title + Value)
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}