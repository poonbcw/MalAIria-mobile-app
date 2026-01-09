import 'package:flutter/material.dart';
import '../../core/storage/auth_storage.dart';
import '../dashboard/dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final isSmallScreen = height < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // --- HEADER ---
                      // ปรับสัดส่วนให้ Header ดูโปร่งขึ้น
                      SizedBox(
                        height: isSmallScreen ? height * 0.38 : height * 0.42,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2), // ดันโลโก้ลงมานิดหน่อย
                            Hero(
                              tag: 'app-logo',
                              child: Image.asset(
                                'assets/images/whiteLogo.png',
                                width: isSmallScreen ? 60 : 68,
                                height: isSmallScreen ? 60 : 68,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Medical Analysis',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 22 : 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 3.5, // เพิ่ม letter spacing ให้ดูพรีเมียม
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Secure access with Google account',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ),

                      // --- LOGIN CARD ---
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            32,
                            isSmallScreen ? 40 : 56, // เพิ่ม padding บนให้ดูโล่ง
                            32,
                            48, // เพิ่ม padding ล่างเพื่อความสวยงาม
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(44), // มนขึ้นเล็กน้อยเพื่อให้ดู Modern
                              topRight: Radius.circular(44),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Icon Indicator
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F3F5),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 24,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 26 : 30,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF0A0A0A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Sign in with your Google account',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              
                              const Spacer(), // ใช้ Spacer แทน SizedBox เพื่อให้ปุ่มจัดวางตามขนาดจอ

                              // GOOGLE BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 60, // ปรับปุ่มให้สูงขึ้นเพื่อให้กดง่ายและดูเต็ม
                                child: OutlinedButton(
                                  onPressed: () {
                                    AuthStorage.login();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DashboardPage(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.black.withOpacity(0.08),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google_logo.png',
                                        width: 22,
                                        height: 22,
                                      ),
                                      const SizedBox(width: 14),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const Spacer(), // สร้างระยะห่างด้านล่างปุ่มให้สมดุล
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}