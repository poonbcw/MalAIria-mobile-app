import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'core/storage/auth_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // เรียกใช้งาน Firebase
  await Firebase.initializeApp(); 
  await AuthStorage.init(); 
  runApp(
    ProviderScope(
      child: const MalAIriaApp(),
    ),
  );
}