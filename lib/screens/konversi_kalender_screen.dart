import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

const List<String> _namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const List<String> _namaPasaran = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
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
      appBar: buildAppBar('Konversi Kalender'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _TombolTab(label: 'Weton Jawa', aktif: _tabAktif == 0, onTap: () => setState(() => _tabAktif = 0))),
                  const SizedBox(width: 10),
                  Expanded(child: _TombolTab(label: 'Saka Bali', aktif: _tabAktif == 1, onTap: () => setState(() => _tabAktif = 1))),
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: aktif ? kPrimaryColor : Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: aktif ? Colors.white : kTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
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
    final int indexPasaran = selisihHari % 5;
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pilih tanggal', style: TextStyle(fontSize: 13, color: kTextMuted)),
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
            onPressed: _hitungWeton,
            style: kPrimaryButtonStyle,
            child: const Text('Cari Weton', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (hari != null && pasaran != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  const Text('WETON', style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('$hari $pasaran', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pasaran dihitung dari acuan 17 Agustus 1945 (Jumat Legi).',
              style: TextStyle(fontSize: 11, color: kTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// KONVERSI TAHUN SAKA BALI (pendekatan sederhana)
// -----------------------------------------------------------------------
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
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
        _tahunSaka = null;
      });
    }
  }

  void _hitungSaka() {
    setState(() {
      _tahunSaka = _tanggalDipilih.year - 78;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int? tahunSaka = _tahunSaka;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kAccentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Text(
              'Catatan: ini hanya konversi TAHUN Saka (Masehi - 78), pendekatan '
              'yang umum dipakai. Kalender Saka Bali sesungguhnya memakai sistem '
              'wuku & pawukon yang jauh lebih kompleks dan tidak dihitung penuh '
              'di sini.',
              style: TextStyle(fontSize: 12, color: kTextMuted),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pilih tanggal', style: TextStyle(fontSize: 13, color: kTextMuted)),
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
            onPressed: _hitungSaka,
            style: kPrimaryButtonStyle,
            child: const Text('Konversi ke Tahun Saka', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (tahunSaka != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  const Text('TAHUN SAKA', style: TextStyle(fontSize: 12, color: Colors.white70, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('$tahunSaka', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
