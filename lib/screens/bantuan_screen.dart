// =======================================================================
// HALAMAN BANTUAN
// Berisi cara penggunaan aplikasi dan menu Logout (sesuai soal).
// =======================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const List<Map<String, String>> _panduan = [
    {
      'judul': 'Login',
      'isi': 'Masuk menggunakan username & password akun kalian. Status login '
          'tetap tersimpan (session) walau aplikasi ditutup, sampai kalian '
          'menekan tombol Logout di bawah.',
    },
    {
      'judul': 'Daftar Anggota',
      'isi': 'Menampilkan nama & NIM anggota kelompok pembuat aplikasi ini.',
    },
    {
      'judul': 'Komputasi Kesehatan',
      'isi': 'Kalkulator BMI (Indeks Massa Tubuh) dan kebutuhan kalori harian '
          '(BMR/TDEE). Isi data lalu tekan tombol Hitung.',
    },
    {
      'judul': 'Catatan Aktivitas Olahraga',
      'isi': 'Tambah catatan olahraga lewat tombol +, ubah lewat ikon pensil, '
          'atau hapus lewat ikon tempat sampah. Data tersimpan di database '
          'dan langsung ter-update untuk semua anggota.',
    },
    {
      'judul': 'Konversi Tanggal & Kalender',
      'isi': 'Pilih tanggal lewat kalender, lalu tekan tombol konversi untuk '
          'melihat tanggal Hijriah, umur, weton, atau tahun Saka.',
    },
    {
      'judul': 'Stopwatch',
      'isi': 'Tekan Mulai/Jeda untuk menjalankan stopwatch, Lap untuk mencatat '
          'waktu tanpa menghentikan hitungan, dan Reset untuk mengulang dari 0.',
    },
  ];

  Future<void> _logout(BuildContext context) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kalian perlu login kembali untuk masuk ke aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: kWarningColor)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await Supabase.instance.client.auth.signOut();
      // AuthGate di main.dart otomatis mengalihkan ke LoginScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Bantuan'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Cara Penggunaan Aplikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kPrimaryDark)),
            const SizedBox(height: 14),
            for (final item in _panduan)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['judul'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimaryColor)),
                    const SizedBox(height: 6),
                    Text(item['isi'] ?? '', style: const TextStyle(fontSize: 13, color: kTextMuted, height: 1.4)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kWarningColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
