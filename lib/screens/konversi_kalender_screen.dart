import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

const List<String> _namaHari = [
  'SENIN',
  'SELASA',
  'RABU',
  'KAMIS',
  'JUMAT',
  'SABTU',
  'MINGGU',
];

const List<String> _namaPasaran = ['LEGI', 'PAHING', 'PON', 'WAGE', 'KLIWON'];

// Acuan pasaran: 17 Agustus 1945 bertepatan dengan hari Jumat Legi
final DateTime _tanggalAcuanPasaran = DateTime(1945, 8, 17);

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
      appBar: buildAppBar('KONVERSI KALENDER'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _TombolTab(
                      label: 'WETON JAWA',
                      aktif: _tabAktif == 0,
                      onTap: () => setState(() => _tabAktif = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TombolTab(
                      label: 'SAKA BALI',
                      aktif: _tabAktif == 1,
                      onTap: () => setState(() => _tabAktif = 1),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tabAktif == 0 ? const _KonversiWeton() : const _KonversiSaka(),
            ),
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

// =========================================================================
// TAB 1: KONVERSI WETON JAWA
// =========================================================================
class _KonversiWeton extends StatefulWidget {
  const _KonversiWeton();

  @override
  State<_KonversiWeton> createState() => _KonversiWetonState();
}

class _KonversiWetonState extends State<_KonversiWeton> {
  DateTime _tanggalDipilih = DateTime.now();
  String? _hari;
  String? _pasaran;
  int? _neptu;

  // Nilai neptu hari & pasaran untuk memperkaya hasil
  final Map<String, int> _neptuHari = {
    'MINGGU': 5,
    'SENIN': 4,
    'SELASA': 3,
    'RABU': 7,
    'KAMIS': 8,
    'JUMAT': 6,
    'SABTU': 9,
  };

  final Map<String, int> _neptuPasaran = {
    'LEGI': 5,
    'PAHING': 9,
    'PON': 7,
    'WAGE': 4,
    'KLIWON': 8,
  };

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(1700), // Diperluas hingga tahun 1700
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryColor,
            onPrimary: Colors.black,
            surface: kSurfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
        _hari = null;
        _pasaran = null;
        _neptu = null;
      });
    }
  }

  void _hitungWeton() {
    final String hari = _namaHari[_tanggalDipilih.weekday - 1];
    final int selisihHari = _tanggalDipilih.difference(_tanggalAcuanPasaran).inDays;
    
    // Modulo positif agar akurat untuk tanggal sebelum 1945
    final int indexPasaran = ((selisihHari % 5) + 5) % 5;
    final String pasaran = _namaPasaran[indexPasaran];
    final int totalNeptu = (_neptuHari[hari] ?? 0) + (_neptuPasaran[pasaran] ?? 0);

    setState(() {
      _hari = hari;
      _pasaran = pasaran;
      _neptu = totalNeptu;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? hari = _hari;
    final String? pasaran = _pasaran;
    final int? neptu = _neptu;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PILIH TANGGAL',
            style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20, color: kPrimaryColor),
                  const SizedBox(width: 16),
                  Text(
                    '${_tanggalDipilih.day}/${_tanggalDipilih.month}/${_tanggalDipilih.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text('Ubah', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungWeton,
            style: kPrimaryButtonStyle,
            child: const Text('HITUNG WETON'),
          ),
          if (hari != null && pasaran != null) ...[
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'HASIL WETON JAWA',
                    style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$hari $pasaran',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Jumlah Neptu: $neptu  (${_neptuHari[hari]} + ${_neptuPasaran[pasaran]})',
                      style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
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

// =========================================================================
// TAB 2: KONVERSI SAKA BALI
// =========================================================================
class _KonversiSaka extends StatefulWidget {
  const _KonversiSaka();

  @override
  State<_KonversiSaka> createState() => _KonversiSakaState();
}

class _KonversiSakaState extends State<_KonversiSaka> {
  DateTime _tanggalDipilih = DateTime.now();
  Map<String, dynamic>? _hasilSaka;

  // Daftar nama 12 Sasih dalam Kalender Saka Bali berdasarkan perkiraan bulan
  static const List<Map<String, String>> _daftarSasih = [
    {'nama': 'Kapitu', 'arti': 'Bulan ke-7 (Masa Hujan Lebat)'},
    {'nama': 'Kawolu', 'arti': 'Bulan ke-8 (Masa Peralihan Menuju Kemarau)'},
    {'nama': 'Kasanga', 'arti': 'Bulan ke-9 (Menjelang Hari Raya Nyepi)'},
    {'nama': 'Kadasa', 'arti': 'Bulan ke-10 (Tahun Baru Saka / Sasih Kedasa)'},
    {'nama': 'Jyestha', 'arti': 'Bulan ke-11 (Masa Panen Raya)'},
    {'nama': 'Asadha', 'arti': 'Bulan ke-12 (Masa Kemarau)'},
    {'nama': 'Kasa', 'arti': 'Bulan ke-1 (Awal Siklus Pertanian/Kartika)'},
    {'nama': 'Karo', 'arti': 'Bulan ke-2 (Masa Tumbuh)'},
    {'nama': 'Katiga', 'arti': 'Bulan ke-3 (Masa Panen Palawija)'},
    {'nama': 'Kapat', 'arti': 'Bulan ke-4 (Masa Bunga Mulai Mekar)'},
    {'nama': 'Kalima', 'arti': 'Bulan ke-5 (Mulai Terlihat Tanda Hujan)'},
    {'nama': 'Kanem', 'arti': 'Bulan ke-6 (Awal Musim Hujan)'},
  ];

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(1700), // Diperluas hingga tahun 1700
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryColor,
            onPrimary: Colors.black,
            surface: kSurfaceColor,
          ),
        ),
        child: child!,
      ),
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
        _hasilSaka = null;
      });
    }
  }

  void _hitungSaka() {
    // Kalender Saka dimulai tahun 78 Masehi
    final int tahunSaka = _tanggalDipilih.year - 78;
    final int indexBulan = _tanggalDipilih.month - 1;
    final Map<String, String> sasihInfo = _daftarSasih[indexBulan];

    setState(() {
      _hasilSaka = {
        'tahunSaka': tahunSaka,
        'sasih': sasihInfo['nama'],
        'maknaSasih': sasihInfo['arti'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? hasil = _hasilSaka;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.15)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: kPrimaryColor, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kalender Saka Bali dimulai sejak tahun 78 Masehi. Pergantian tahun baru Saka dirayakan saat Hari Suci Nyepi pada Tilem Kesanga.',
                    style: TextStyle(fontSize: 12, color: kTextMuted, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'PILIH TANGGAL',
            style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20, color: kPrimaryColor),
                  const SizedBox(width: 16),
                  Text(
                    '${_tanggalDipilih.day}/${_tanggalDipilih.month}/${_tanggalDipilih.year}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Text('Ubah', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungSaka,
            style: kPrimaryButtonStyle,
            child: const Text('KONVERSI KE SAKA'),
          ),
          if (hasil != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'TAHUN SAKA BALI',
                    style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${hasil['tahunSaka']} SAKA',
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  _buildItemInfo(
                    label: 'Perkiraan Sasih',
                    nilai: '${hasil['sasih']} (${hasil['maknaSasih']})',
                    icon: Icons.wb_twilight_rounded,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemInfo({required String label, required String nilai, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: kPrimaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                nilai,
                style: const TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}