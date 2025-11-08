import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'core/app_export.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تهيئة Supabase
  try {
    await Supabase.initialize(
      url: 'https://pnydbwibckublrajloxo.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBueWRid2liY2t1YmxyYWpsb3hvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1MjA4NzMsImV4cCI6MjA3NjA5Njg3M30.QAQAiZlVy4aZnVqg0BRuHbJDxBABGPt9taHZmInqySU',
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Supabase init failed: $e');
  }

  // ✅ تهيئة Firebase
  try {

    
    debugPrint('🔥 Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase init failed: $e');
  }

  // 🔒 قفل الاتجاه على الوضع العمودي فقط
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);


final client = Supabase.instance.client;
debugPrint('Supabase URL: ${client.supabaseUrl}');
debugPrint('Supabase Key: ${client.supabaseKey}');


  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    debugPrint('✅ Supabase user ID: ${user.id}, email: ${user.email}');
  } else {
    debugPrint('❌ Not authenticated');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final supabase = Supabase.instance.client;
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final session = supabase.auth.currentSession;
    setState(() {
      _loggedIn = session != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🕐 شاشة تحميل مؤقتة
    if (_loading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // 🎯 التطبيق الرئيسي
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'FitMotion',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          routes: AppRoutes.routes,
          initialRoute:
              _loggedIn ? AppRoutes.homeDashboardScreen : AppRoutes.initial,
        );
      },
    );
  }
  
}
