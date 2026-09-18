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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Aplikasi $temaKelompok',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kTextMuted),
                ),
                const SizedBox(height: 20),
                VerticalMenuItem(
                  icon: Icons.groups,
                  label: 'Daftar Anggota',
                  subtitle: 'Anggota kelompok pembuat aplikasi',
                  color: kPrimaryColor,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarAnggotaScreen()));
                  },
                ),
                VerticalMenuItem(
                  icon: Icons.monitor_weight,
                  label: 'Komputasi Kesehatan',
                  subtitle: 'Kalkulator BMI & kebutuhan kalori harian',
                  color: kAccentColor,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KomputasiScreen()));
                  },
                ),
                VerticalMenuItem(
                  icon: Icons.fitness_center,
                  label: 'Catatan Aktivitas Olahraga',
                  subtitle: 'Tambah, lihat, ubah, hapus catatan olahraga',
                  color: kSuccessColor,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CrudOlahragaScreen()));
                  },
                ),
                VerticalMenuItem(
                  icon: Icons.calendar_month,
                  label: 'Konversi Tanggal',
                  subtitle: 'Tanggal Hijriah & umur dari tanggal lahir',
                  color: kPrimaryDark,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KonversiTanggalScreen()));
                  },
                ),
                VerticalMenuItem(
                  icon: Icons.brightness_5,
                  label: 'Konversi Kalender',
                  subtitle: 'Kalender Weton Jawa & Saka Bali',
                  color: kWarningColor,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KonversiKalenderScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
