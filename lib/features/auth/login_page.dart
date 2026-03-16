import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_sign_in/google_sign_in.dart'; 
import '../../core/storage/auth_storage.dart';
import '../../core/api/api_config.dart'; 

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // --- ฟังก์ชันหลักสำหรับ Google Sign-In ---
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      
      if (googleUser == null) return; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final String? firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken != null) {
        print("🎉 ล็อกอินสำเร็จ! ชื่อ: ${userCredential.user?.displayName}");
        
        // =================================================================
        // 🚀 เพิ่มใหม่: ยิง API ไปบอก Backend ให้สร้าง User ลง Postgres
        // =================================================================
        try {
          final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/google');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': firebaseToken}),
          );

          if (response.statusCode == 200) {
            print("✅ ซิงค์ข้อมูล User ลง Postgres เรียบร้อยแล้ว!");
          } else {
            print("❌ ซิงค์ข้อมูลล้มเหลว: ${response.statusCode} - ${response.body}");
          }
        } catch (e) {
          print("❌ เชื่อมต่อ Backend ไม่ได้ตอน Sync User: $e");
        }
        // =================================================================
        
        // บันทึก Token ลงเครื่องแล้วพาไปหน้า Dashboard
        await AuthStorage.saveToken(firebaseToken); 
        
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        }
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการล็อกอิน: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final isSmallScreen = height < 700;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 27, 50),
      // ✅ ให้เนื้อหาไหลทะลุไปอยู่หลัง AppBar (Layout จะได้ไม่เพี้ยน)
      extendBodyBehindAppBar: true, 
      
      // ✅ เพิ่ม AppBar โปร่งใสพร้อมปุ่ม Back
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context); // กดแล้วกลับไปหน้าเดิม (Dashboard)
          },
        ),
      ),
      
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
                      SizedBox(
                        height: isSmallScreen ? height * 0.38 : height * 0.42,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
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
                                letterSpacing: 3.5,
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
                            isSmallScreen ? 40 : 56,
                            32,
                            48,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(44),
                              topRight: Radius.circular(44),
                            ),
                          ),
                          child: Column(
                            children: [
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

                              const Spacer(),
                              
                              // --- GOOGLE BUTTON ---
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: OutlinedButton(
                                  onPressed: () => signInWithGoogle(context), 
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

                              const Spacer(),
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