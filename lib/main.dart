import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

import 'utils/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SyncService.init();
  final prefs = await SharedPreferences.getInstance();
  final String? username = prefs.getString('username');
  
  runApp(MyApp(
    initialScreen: username == null || username.isEmpty 
        ? const LoginScreen() 
        : const HomeScreen(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BGMax',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A00E0)),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: initialScreen,
    );
  }
}
