import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

const String kDomainEmailAkun = 'gmail.com';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _sedangProses = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _sedangProses = true;
      _errorMessage = null;
    });

    final String email = '$username@$kDomainEmailAkun';

    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      // Navigasi ditangani otomatis oleh AuthGate di main.dart lewat onAuthStateChange
    } on AuthException catch (e) {
      String pesan;
      final String pesanAsli = e.message.toLowerCase();
      if (pesanAsli.contains('invalid login credentials') || pesanAsli.contains('invalid_credentials')) {
        pesan = 'Username atau password salah.';
      } else if (pesanAsli.contains('email not confirmed')) {
        pesan = 'Akun belum dikonfirmasi. Aktifkan "Auto Confirm User" saat membuat akun di Supabase Dashboard.';
      } else if (pesanAsli.contains('network') || pesanAsli.contains('failed host lookup')) {
        pesan = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      } else {
        pesan = 'Login gagal: ${e.message}';
      }
      setState(() {
        _errorMessage = pesan;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan tak terduga: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _sedangProses = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 24),
                const Text(
                  namaAplikasi,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryDark),
                ),
                const SizedBox(height: 6),
                Text(
                  'Aplikasi $temaKelompok',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: _usernameController,
                  enabled: !_sedangProses,
                  decoration: buildInputDecoration('Username', prefixIcon: const Icon(Icons.person)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_sedangProses,
                  onSubmitted: (_) => _login(),
                  decoration: buildInputDecoration(
                    'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  ErrorBox(message: _errorMessage!),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _sedangProses ? null : _login,
                  style: kPrimaryButtonStyle,
                  child: _sedangProses
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
