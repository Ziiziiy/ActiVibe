// =======================================================================
// HALAMAN KONVERSI TANGGAL
// Berisi 2 konversi: Masehi -> Hijriah (pakai paket `hijri`), dan
// tanggal lahir -> umur (tahun, bulan, hari, jam, menit, detik).
// =======================================================================

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

class KonversiTanggalScreen extends StatefulWidget {
  const KonversiTanggalScreen({super.key});

  @override
  State<KonversiTanggalScreen> createState() => _KonversiTanggalScreenState();
}

class _KonversiTanggalScreenState extends State<KonversiTanggalScreen> {
  int _tabAktif = 0; // 0 = Hijriah, 1 = Umur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Konversi Tanggal'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _TombolTab(label: 'Masehi -> Hijriah', aktif: _tabAktif == 0, onTap: () => setState(() => _tabAktif = 0))),
                  const SizedBox(width: 10),
                  Expanded(child: _TombolTab(label: 'Umur', aktif: _tabAktif == 1, onTap: () => setState(() => _tabAktif = 1))),
                ],
              ),
            ),
            Expanded(child: _tabAktif == 0 ? const _KonversiHijriah() : const _KonversiUmur()),
          ],
        ),
      ),
    );
  }
}

class _TombolTab extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _TombolTab({required this.label, required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: aktif ? kPrimaryColor : Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: aktif ? Colors.white : kTextMuted, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// KONVERSI MASEHI -> HIJRIAH
// -----------------------------------------------------------------------
class _KonversiHijriah extends StatefulWidget {
  const _KonversiHijriah();

  @override
  State<_KonversiHijriah> createState() => _KonversiHijriahState();
}

class _KonversiHijriahState extends State<_KonversiHijriah> {
  DateTime _tanggalDipilih = DateTime.now();
  HijriCalendar? _hasilHijriah;

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
        _hasilHijriah = null;
      });
    }
  }

  void _konversi() {
    setState(() {
      _hasilHijriah = HijriCalendar.fromDate(_tanggalDipilih);
    });
  }

  @override
  Widget build(BuildContext context) {
    final HijriCalendar? hijriah = _hasilHijriah;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pilih tanggal Masehi', style: TextStyle(fontSize: 13, color: kTextMuted)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: kTextMuted),
                  const SizedBox(width: 12),
                  Text('${_tanggalDipilih.day}/${_tanggalDipilih.month}/${_tanggalDipilih.year}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _konversi,
            style: kPrimaryButtonStyle,
            child: const Text('Konversi ke Hijriah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (hijriah != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  const Text('TANGGAL HIJRIAH', style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    '${hijriah.hDay} ${hijriah.getLongMonthName()} ${hijriah.hYear} H',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// KONVERSI TANGGAL LAHIR -> UMUR
// -----------------------------------------------------------------------
class _KonversiUmur extends StatefulWidget {
  const _KonversiUmur();

  @override
  State<_KonversiUmur> createState() => _KonversiUmurState();
}

class _KonversiUmurState extends State<_KonversiUmur> {
  DateTime _tanggalLahir = DateTime(2000, 1, 1);
  Map<String, int>? _hasilUmur;

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (hasil != null) {
      setState(() {
        _tanggalLahir = hasil;
        _hasilUmur = null;
      });
    }
  }

  void _hitungUmur() {
    final DateTime sekarang = DateTime.now();

    int tahun = sekarang.year - _tanggalLahir.year;
    int bulan = sekarang.month - _tanggalLahir.month;
    int hari = sekarang.day - _tanggalLahir.day;

    if (hari < 0) {
      bulan -= 1;
      final DateTime bulanSebelumnya = DateTime(sekarang.year, sekarang.month, 0);
      hari += bulanSebelumnya.day;
    }
    if (bulan < 0) {
      tahun -= 1;
      bulan += 12;
    }

    final Duration selisih = sekarang.difference(_tanggalLahir);

    setState(() {
      _hasilUmur = {
        'tahun': tahun,
        'bulan': bulan,
        'hari': hari,
        'totalHari': selisih.inDays,
        'totalJam': selisih.inHours,
        'totalMenit': selisih.inMinutes,
        'totalDetik': selisih.inSeconds,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int>? umur = _hasilUmur;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pilih tanggal lahir', style: TextStyle(fontSize: 13, color: kTextMuted)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.cake, size: 18, color: kTextMuted),
                  const SizedBox(width: 12),
                  Text('${_tanggalLahir.day}/${_tanggalLahir.month}/${_tanggalLahir.year}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _hitungUmur,
            style: kPrimaryButtonStyle,
            child: const Text('Hitung Umur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (umur != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(18)),
              child: Text(
                '${umur['tahun']} tahun ${umur['bulan']} bulan ${umur['hari']} hari',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),
            InfoCard(label: 'Total hari', value: '${umur['totalHari']} hari'),
            InfoCard(label: 'Total jam', value: '${umur['totalJam']} jam'),
            InfoCard(label: 'Total menit', value: '${umur['totalMenit']} menit'),
            InfoCard(label: 'Total detik', value: '${umur['totalDetik']} detik'),
          ],
        ],
      ),
    );
  }
}
