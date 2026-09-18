import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/app_data.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

const String kSupabaseUrl = 'https://dmulakaqpvluyjxhykab.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtdWxha2FxcHZsdXlqeGh5a2FiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk2MTM2NzUsImV4cCI6MjEwNTE4OTY3NX0.ff9daoyb-HvtLEG4VuWiWXp_GE9UmfrP_xfNX4obit0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: deprecated_member_use
  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: namaAplikasi,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.dark,
          primary: kPrimaryColor,
          surface: kSurfaceColor,
          surfaceContainer: kSurfaceColor,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final Session? session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginScreen();
        }
        return const MainShell();
      },
    );
  }
}
