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
        _errorMessage = 'Username dan kata sandi wajib diisi.';
      });
      return;
    }

    setState(() {
      _sedangProses = true;
      _errorMessage = null;
    });

    final String email = '$username@$kDomainEmailAkun';

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      String pesan;
      final String pesanAsli = e.message.toLowerCase();
      if (pesanAsli.contains('invalid login credentials') ||
          pesanAsli.contains('invalid_credentials')) {
        pesan = 'Username atau kata sandi salah.';
      } else if (pesanAsli.contains('email not confirmed')) {
        pesan = 'Akun belum dikonfirmasi.';
      } else if (pesanAsli.contains('network')) {
        pesan = 'Tidak ada koneksi internet.';
      } else {
        pesan = 'Gagal masuk: ${e.message}';
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
            // Bagian Atas: Logo Aplikasi (dikembalikan ke 0.46 tinggi layar)
            Container(
              height: MediaQuery.of(context).size.height * 0.46,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: const BoxDecoration(
                color: kBackgroundColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fitness_center_rounded,
                          color: kPrimaryColor,
                          size: 72,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Column(
                    children: [
                      Text(
                        namaAplikasi,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SISTEM KESEHATAN & KEBUGARAN',
                        style: TextStyle(
                          color: kTextMuted,
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bagian Bawah: Form Input (padding atas dikembalikan ke 56)
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.54,
              ),
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
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildReferenceInput(
                    controller: _usernameController,
                    hint: 'Masukkan username kamu',
                    enabled: !_sedangProses,
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildReferenceInput(
                    controller: _passwordController,
                    hint: 'Masukkan kata sandi kamu',
                    obscure: _obscurePassword,
                    enabled: !_sedangProses,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: kPrimaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white54,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    ErrorBox(message: _errorMessage!),
                  ],
                  // Jika ada error, jarak ke tombol diperpendek agar tombol tidak terdorong jauh
                  SizedBox(height: _errorMessage != null ? 20 : 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sedangProses ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: _sedangProses
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'MASUK',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
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
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    // Definisi bentuk border dasar melengkung
    final OutlineInputBorder outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.white10, width: 1.5),
    );

    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white60,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white24,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        filled: true,
        fillColor: kBackgroundColor,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        // Kunci perbaikan: Menjaga outline dan lekukan tetap ada saat disabled/loading
        disabledBorder: outlineBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
      ),
    );
  }
}