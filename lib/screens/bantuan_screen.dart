import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  static const List<Map<String, String>> _panduan = [
    {
      'judul': 'SISTEM LOGIN',
      'isi':
          'Masuk menggunakan akun terdaftar. Sesi login tersimpan secara otomatis walau aplikasi ditutup hingga kamu menekan tombol keluar.',
    },
    {
      'judul': 'DAFTAR ANGGOTA',
      'isi':
          'Menampilkan informasi profil, nama lengkap, dan NIM seluruh anggota kelompok pembuat aplikasi.',
    },
    {
      'judul': 'KOMPUTASI KESEHATAN',
      'isi':
          'Kalkulator indeks massa tubuh (BMI) dan kebutuhan kalori harian (BMR & TDEE) otomatis berbasis data profil fisik.',
    },
    {
      'judul': 'CATATAN OLAHRAGA',
      'isi':
          'Kelola catatan latihan fisik harian (tambah, edit, dan hapus) yang tersinkronisasi langsung ke database cloud secara real-time.',
    },
    {
      'judul': 'KONVERSI TANGGAL',
      'isi':
          'Pilih tanggal acuan untuk menghitung umur lengkap (tahun, bulan, dan hari), hari pasaran (weton Jawa), serta total selisih hari latihan.',
    },
    {
      'judul': 'KONVERSI KALENDER',
      'isi':
          'Navigasi kalender interaktif untuk melihat padanan penanggalan Masehi ke sistem kalender Hijriah dan tahun Saka.',
    },
    {
      'judul': 'STOPWATCH',
      'isi':
          'Pengukur durasi latihan fisik dengan fitur Lap untuk mencatat split time atau putaran tanpa menghentikan hitungan waktu.',
    },
  ];

  Future<void> _logout(BuildContext context) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'KELUAR AKUN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun aplikasi?',
          style: TextStyle(color: kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'YA, KELUAR',
              style: TextStyle(color: kWarningColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('PANDUAN'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const Text(
              'PANDUAN PENGGUNAAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: kPrimaryColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            for (final item in _panduan)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['judul'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['isi'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: kTextMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kWarningColor.withValues(alpha: 0.1),
                foregroundColor: kWarningColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: kWarningColor, width: 1.5),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'KELUAR DARI AKUN',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}