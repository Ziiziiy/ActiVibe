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
    } on AuthException catch (e) {
      String pesan;
      final String pesanAsli = e.message.toLowerCase();
      if (pesanAsli.contains('invalid login credentials') || pesanAsli.contains('invalid_credentials')) {
        pesan = 'Username atau password salah.';
      } else if (pesanAsli.contains('email not confirmed')) {
        pesan = 'Akun belum dikonfirmasi.';
      } else if (pesanAsli.contains('network')) {
        pesan = 'Tidak ada koneksi internet.';
      } else {
        pesan = 'Login gagal: ${e.message}';
      }
      setState(() {
        _errorMessage = pesan;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
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
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Logo Focus)
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: const BoxDecoration(
                color: kBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Prominent Logo instead of "LOG IN" text
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.bolt_rounded, color: kPrimaryColor, size: 120),
                  ),
                  const SizedBox(height: 24),
                  const Column(
                    children: [
                      Text(
                        namaAplikasi,
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'HEALTH & FITNESS SYSTEM',
                        style: TextStyle(color: kTextMuted, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Section (Dark Surface Container)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.55),
              padding: const EdgeInsets.fromLTRB(32, 56, 32, 40),
              decoration: const BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Username',
                    style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  _buildReferenceInput(
                    controller: _usernameController,
                    hint: 'Enter your username',
                    enabled: !_sedangProses,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Password',
                    style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                  ),
                  const SizedBox(height: 12),
                  _buildReferenceInput(
                    controller: _passwordController,
                    hint: 'Enter your password',
                    obscure: _obscurePassword,
                    enabled: !_sedangProses,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 24),
                    ErrorBox(message: _errorMessage!),
                  ],
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sedangProses ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: _sedangProses
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                            )
                          : const Text(
                              'SIGN IN',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInput({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 14),
        filled: true,
        fillColor: kBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white10, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
      ),
    );
  }
}
