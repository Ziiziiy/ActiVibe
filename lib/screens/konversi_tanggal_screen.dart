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
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('KONVERSI'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _TombolTab(label: 'HIJRIAH', aktif: _tabAktif == 0, onTap: () => setState(() => _tabAktif = 0))),
                  const SizedBox(width: 12),
                  Expanded(child: _TombolTab(label: 'UMUR', aktif: _tabAktif == 1, onTap: () => setState(() => _tabAktif = 1))),
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: aktif ? kPrimaryColor : kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: aktif ? kPrimaryColor : Colors.white10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: aktif ? Colors.black : kTextMuted,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

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
      firstDate: DateTime(1500),
      lastDate: DateTime(2500),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: kPrimaryColor, onPrimary: Colors.black, surface: kSurfaceColor),
          ),
          child: child!,
        );
      },
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Masukan Tanggal', style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20, color: kPrimaryColor),
                  const SizedBox(width: 16),
                  Text(
                    '${_tanggalDipilih.day}/${_tanggalDipilih.month}/${_tanggalDipilih.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _konversi,
            style: kPrimaryButtonStyle,
            child: const Text('UBAH KE HIJRIAH'),
          ),
          if (hijriah != null) ...[
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text('HIJRI DATE', style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text(
                    '${hijriah.hDay} ${hijriah.getLongMonthName()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kPrimaryColor),
                  ),
                  Text(
                    '${hijriah.hYear} AH',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
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
      firstDate: DateTime(1500),
      lastDate: DateTime(2500),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: kPrimaryColor, onPrimary: Colors.black, surface: kSurfaceColor),
          ),
          child: child!,
        );
      },
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Masukan Tanggal Lahir', style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  const Icon(Icons.cake_rounded, size: 20, color: kPrimaryColor),
                  const SizedBox(width: 16),
                  Text(
                    '${_tanggalLahir.day}/${_tanggalLahir.month}/${_tanggalLahir.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungUmur,
            style: kPrimaryButtonStyle,
            child: const Text('HITUNG UMUR'),
          ),
          if (umur != null) ...[
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text('UMUR SEKARANG', style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(
                    '${umur['tahun']}Y ${umur['bulan']}M ${umur['hari']}D',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: kPrimaryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
