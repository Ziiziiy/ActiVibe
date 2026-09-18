import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';
import 'daftar_anggota_screen.dart';
import 'komputasi_screen.dart';
import 'crud_olahraga_screen.dart';
import 'konversi_tanggal_screen.dart';
import 'konversi_kalender_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(namaAplikasi),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'APLIKASI $temaKelompok',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 32),
              VerticalMenuItem(
                icon: Icons.groups_rounded,
                label: 'Daftar Anggota',
                subtitle: 'Tim pengembang ActiVibe',
                color: kPrimaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAnggotaScreen()));
                },
              ),
              VerticalMenuItem(
                icon: Icons.monitor_weight_rounded,
                label: 'Komputasi Kesehatan',
                subtitle: 'BMI & Kebutuhan Kalori',
                color: kPrimaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const KomputasiScreen()));
                },
              ),
              VerticalMenuItem(
                icon: Icons.fitness_center_rounded,
                label: 'Catatan Olahraga',
                subtitle: 'Kelola aktivitas harian',
                color: kPrimaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CrudOlahragaScreen()));
                },
              ),
              VerticalMenuItem(
                icon: Icons.calendar_today_rounded,
                label: 'Konversi Tanggal',
                subtitle: 'Hijriah & Hitung Umur',
                color: kPrimaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const KonversiTanggalScreen()));
                },
              ),
              VerticalMenuItem(
                icon: Icons.auto_awesome_mosaic_rounded,
                label: 'Konversi Kalender',
                subtitle: 'Weton Jawa & Saka Bali',
                color: kPrimaryColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const KonversiKalenderScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
