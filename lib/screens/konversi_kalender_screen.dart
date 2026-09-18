import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

const List<String> _namaHari = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];
const List<String> _namaPasaran = ['LEGI', 'PAHING', 'PON', 'WAGE', 'KLIWON'];
final DateTime _tanggalAcuanPasaran = DateTime(1945, 8, 17); // Jumat Legi

class KonversiKalenderScreen extends StatefulWidget {
  const KonversiKalenderScreen({super.key});

  @override
  State<KonversiKalenderScreen> createState() => _KonversiKalenderScreenState();
}

class _KonversiKalenderScreenState extends State<KonversiKalenderScreen> {
  int _tabAktif = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('CALENDAR'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _TombolTab(label: 'WETON', aktif: _tabAktif == 0, onTap: () => setState(() => _tabAktif = 0))),
                  const SizedBox(width: 12),
                  Expanded(child: _TombolTab(label: 'SAKA', aktif: _tabAktif == 1, onTap: () => setState(() => _tabAktif = 1))),
                ],
              ),
            ),
            Expanded(child: _tabAktif == 0 ? const _KonversiWeton() : const _KonversiSaka()),
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

class _KonversiWeton extends StatefulWidget {
  const _KonversiWeton();

  @override
  State<_KonversiWeton> createState() => _KonversiWetonState();
}

class _KonversiWetonState extends State<_KonversiWeton> {
  DateTime _tanggalDipilih = DateTime.now();
  String? _hari;
  String? _pasaran;

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: kPrimaryColor, onPrimary: Colors.black, surface: kSurfaceColor)),
        child: child!,
      ),
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
        _hari = null;
        _pasaran = null;
      });
    }
  }

  void _hitungWeton() {
    final String hari = _namaHari[_tanggalDipilih.weekday - 1];
    final int selisihHari = _tanggalDipilih.difference(_tanggalAcuanPasaran).inDays;
    final int indexPasaran = (selisihHari % 5).abs();
    final String pasaran = _namaPasaran[indexPasaran];

    setState(() {
      _hari = hari;
      _pasaran = pasaran;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? hari = _hari;
    final String? pasaran = _pasaran;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('SELECT DATE', style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungWeton,
            style: kPrimaryButtonStyle,
            child: const Text('FIND WETON'),
          ),
          if (hari != null && pasaran != null) ...[
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
                  const Text('JAVA WETON', style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text('$hari $pasaran', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kPrimaryColor)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KonversiSaka extends StatefulWidget {
  const _KonversiSaka();

  @override
  State<_KonversiSaka> createState() => _KonversiSakaState();
}

class _KonversiSakaState extends State<_KonversiSaka> {
  DateTime _tanggalDipilih = DateTime.now();
  int? _tahunSaka;

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: kPrimaryColor, onPrimary: Colors.black, surface: kSurfaceColor)),
        child: child!,
      ),
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
        _tahunSaka = null;
      });
    }
  }

  void _hitungSaka() {
    setState(() => _tahunSaka = _tanggalDipilih.year - 78);
  }

  @override
  Widget build(BuildContext context) {
    final int? tahunSaka = _tahunSaka;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1))),
            child: const Text(
              'NOTE: This conversion uses the standard Masehi - 78 formula for the Balinese Saka year.',
              style: TextStyle(fontSize: 12, color: kTextMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          const Text('SELECT DATE', style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungSaka,
            style: kPrimaryButtonStyle,
            child: const Text('CONVERT TO SAKA'),
          ),
          if (tahunSaka != null) ...[
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
                  const Text('SAKA YEAR', style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text('$tahunSaka', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: kPrimaryColor)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
