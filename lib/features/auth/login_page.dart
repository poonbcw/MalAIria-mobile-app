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
                      // HEADER
                      SizedBox(
                        height: isSmallScreen ? height * 0.40 : height * 0.45,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'app-logo',
                                child: Image.asset(
                                  'assets/images/whiteLogo.png',
                                  width: isSmallScreen ? 64 : 72,
                                  height: isSmallScreen ? 64 : 72,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Medical Analysis',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 22 : 26,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Secure access with Google account',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 13,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // LOGIN CARD
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            32,
                            isSmallScreen ? 32 : 48,
                            32,
                            32,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 26,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 24 : 36),
                              Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 26 : 32,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF0A0A0A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in with your Google account',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 32 : 48),

                              // GOOGLE BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 56,
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
                                    side: const BorderSide(
                                      color: Color(0xFFE8E8E8),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google_logo.png',
                                        width: 20,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const Spacer(),
                              Text(
                                'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
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
