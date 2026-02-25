import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_tag_app/firebase_options.dart';
import 'package:smart_tag_app/core/theme/app_theme.dart';
import 'package:smart_tag_app/providers/theme_provider.dart';
import 'package:smart_tag_app/services/auth_service.dart';
import 'package:smart_tag_app/services/iot_tag_service.dart';
import 'package:smart_tag_app/services/iot_tag_data_service.dart';
import 'package:smart_tag_app/services/gsm_tag_service.dart';
import 'package:smart_tag_app/services/sync_service.dart';
import 'package:smart_tag_app/services/tag_auth_service.dart';
import 'package:smart_tag_app/screens/auth/login_screen.dart';
import 'package:smart_tag_app/screens/home_screen.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO: Send to crash reporting service (e.g., Firebase Crashlytics)
    }
  };
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) print('✅ Firebase initialized successfully');
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      if (kDebugMode) print('⚠️ Firebase already initialized, skipping...');
    } else {
      if (kDebugMode) print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => IoTTagService()),
        ChangeNotifierProvider(create: (_) => IoTTagDataService()),
        ChangeNotifierProvider(create: (_) => GsmTagService()),
        ChangeNotifierProvider(create: (_) => TagAuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _syncTimer;
  late TagAuthService _tagAuthService;

  @override
  void initState() {
    super.initState();
    _startAutoSync();
    
    // Start listening for auto-auth tags
    _tagAuthService = Provider.of<TagAuthService>(context, listen: false);
    _tagAuthService.startListeningForAutoAuth();
  }

  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      SyncService().syncToCloud();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _tagAuthService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final tagAuthService = Provider.of<TagAuthService>(context);
    
    // Auto-login when a tag is detected
    if (tagAuthService.autoAuthUserId != null && !authService.isAuthenticated) {
      // Trigger auto-login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performAutoLogin(authService, tagAuthService);
      });
    }
    
    return MaterialApp(
      title: 'Ceres Tag Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authService.isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }

  Future<void> _performAutoLogin(AuthService authService, TagAuthService tagAuthService) async {
    final userId = tagAuthService.autoAuthUserId;
    
    if (userId != null) {
      try {
        final userEmail = await _getUserEmail(userId);
        
        if (userEmail != null) {
          if (kDebugMode) print('Auto-authenticating user: $userId');
          tagAuthService.clearAutoAuth();
          // TODO: Implement secure auto-login with Firebase custom tokens
        }
      } catch (e) {
        if (kDebugMode) print('Auto-login failed: $e');
        tagAuthService.clearAutoAuth();
      }
    }
  }

  Future<String?> _getUserEmail(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data()?['email'] as String?;
    } catch (e) {
      if (kDebugMode) print('Error getting user email: $e');
      return null;
    }
  }
}
