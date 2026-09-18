import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';
import '../utils/parsing.dart';

class KomputasiScreen extends StatefulWidget {
  const KomputasiScreen({super.key});

  @override
  State<KomputasiScreen> createState() => _KomputasiScreenState();
}

class _KomputasiScreenState extends State<KomputasiScreen> {
  int _tabAktif = 0; // 0 = BMI, 1 = Kalori

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Komputasi Kesehatan'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _TombolTab(label: 'BMI', aktif: _tabAktif == 0, onTap: () => setState(() => _tabAktif = 0))),
                  const SizedBox(width: 10),
                  Expanded(child: _TombolTab(label: 'Kalori Harian', aktif: _tabAktif == 1, onTap: () => setState(() => _tabAktif = 1))),
                ],
              ),
            ),
            Expanded(child: _tabAktif == 0 ? const _KalkulatorBmi() : const _KalkulatorKalori()),
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
        decoration: BoxDecoration(
          color: aktif ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: aktif ? Colors.white : kTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}

class _KalkulatorBmi extends StatefulWidget {
  const _KalkulatorBmi();

  @override
  State<_KalkulatorBmi> createState() => _KalkulatorBmiState();
}

class _KalkulatorBmiState extends State<_KalkulatorBmi> {
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  String? _errorMessage;
  double? _bmi;

  @override
  void dispose() {
    _beratController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  String _kategoriBmi(double bmi) {
    if (bmi < 18.5) return 'Kurus (Underweight)';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Gemuk (Overweight)';
    return 'Obesitas';
  }

  Color _warnaKategori(double bmi) {
    if (bmi < 18.5) return kAccentColor;
    if (bmi < 25) return kSuccessColor;
    if (bmi < 30) return kAccentColor;
    return kWarningColor;
  }

  void _hitungBmi() {
    final double? berat = parseAngka(_beratController.text);
    final double? tinggiCm = parseAngka(_tinggiController.text);

    if (berat == null || tinggiCm == null) {
      setState(() {
        _errorMessage = 'Isi berat (kg) dan tinggi (cm) dengan angka yang valid.';
        _bmi = null;
      });
      return;
    }
    if (berat <= 0 || tinggiCm <= 0) {
      setState(() {
        _errorMessage = 'Berat dan tinggi harus lebih dari 0.';
        _bmi = null;
      });
      return;
    }

    final double tinggiM = tinggiCm / 100;
    setState(() {
      _errorMessage = null;
      _bmi = berat / (tinggiM * tinggiM);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double? bmi = _bmi;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _beratController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Berat badan (kg)', prefixIcon: const Icon(Icons.monitor_weight)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tinggiController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Tinggi badan (cm)', prefixIcon: const Icon(Icons.height)),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            ErrorBox(message: _errorMessage!),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _hitungBmi,
            style: kPrimaryButtonStyle,
            child: const Text('Hitung BMI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (bmi != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(color: _warnaKategori(bmi).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  const Text('BMI ANDA', style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text(formatAngka(bmi, desimal: 1), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: _warnaKategori(bmi))),
                  const SizedBox(height: 6),
                  Text(_kategoriBmi(bmi), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _warnaKategori(bmi))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kategori: <18.5 Kurus, 18.5-24.9 Normal, 25-29.9 Gemuk, >=30 Obesitas',
              style: TextStyle(fontSize: 11, color: kTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _KalkulatorKalori extends StatefulWidget {
  const _KalkulatorKalori();

  @override
  State<_KalkulatorKalori> createState() => _KalkulatorKaloriState();
}

class _KalkulatorKaloriState extends State<_KalkulatorKalori> {
  final TextEditingController _beratController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();

  String _jenisKelamin = 'Pria';
  double _faktorAktivitas = 1.2;
  String? _errorMessage;
  double? _bmr;
  double? _tdee;

  static const Map<String, double> _pilihanAktivitas = {
    'Jarang olahraga': 1.2,
    'Ringan (1-3x/minggu)': 1.375,
    'Sedang (3-5x/minggu)': 1.55,
    'Berat (6-7x/minggu)': 1.725,
    'Sangat berat (2x/hari)': 1.9,
  };

  @override
  void dispose() {
    _beratController.dispose();
    _tinggiController.dispose();
    _usiaController.dispose();
    super.dispose();
  }

  void _hitungKalori() {
    final double? berat = parseAngka(_beratController.text);
    final double? tinggi = parseAngka(_tinggiController.text);
    final int? usia = parseAngkaBulat(_usiaController.text);

    if (berat == null || tinggi == null || usia == null) {
      setState(() {
        _errorMessage = 'Isi berat (kg), tinggi (cm), dan usia (tahun) dengan angka yang valid.';
        _bmr = null;
      });
      return;
    }
    if (berat <= 0 || tinggi <= 0 || usia <= 0) {
      setState(() {
        _errorMessage = 'Berat, tinggi, dan usia harus lebih dari 0.';
        _bmr = null;
      });
      return;
    }

    double bmr;
    if (_jenisKelamin == 'Pria') {
      bmr = 10 * berat + 6.25 * tinggi - 5 * usia + 5;
    } else {
      bmr = 10 * berat + 6.25 * tinggi - 5 * usia - 161;
    }

    setState(() {
      _errorMessage = null;
      _bmr = bmr;
      _tdee = bmr * _faktorAktivitas;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double? tdee = _tdee;
    final double? bmr = _bmr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Jenis kelamin', style: TextStyle(fontSize: 13, color: kTextMuted)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Pria', style: TextStyle(fontSize: 13)),
                  value: 'Pria',
                  // ignore: deprecated_member_use
                  groupValue: _jenisKelamin,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _jenisKelamin = v ?? 'Pria'),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Wanita', style: TextStyle(fontSize: 13)),
                  value: 'Wanita',
                  // ignore: deprecated_member_use
                  groupValue: _jenisKelamin,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _jenisKelamin = v ?? 'Pria'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _beratController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Berat badan (kg)', prefixIcon: const Icon(Icons.monitor_weight)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tinggiController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Tinggi badan (cm)', prefixIcon: const Icon(Icons.height)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _usiaController,
            keyboardType: TextInputType.number,
            decoration: buildInputDecoration('Usia (tahun)', prefixIcon: const Icon(Icons.cake)),
          ),
          const SizedBox(height: 14),
          const Text('Tingkat aktivitas', style: TextStyle(fontSize: 13, color: kTextMuted)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                value: _faktorAktivitas,
                isExpanded: true,
                items: _pilihanAktivitas.entries
                    .map((e) => DropdownMenuItem<double>(value: e.value, child: Text(e.key, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => _faktorAktivitas = v ?? 1.2),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            ErrorBox(message: _errorMessage!),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _hitungKalori,
            style: kPrimaryButtonStyle,
            child: const Text('Hitung Kebutuhan Kalori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          if (tdee != null && bmr != null) ...[
            const SizedBox(height: 24),
            InfoCard(label: 'BMR (kalori istirahat/basal per hari)', value: '${formatAngka(bmr, desimal: 0)} kkal'),
            InfoCard(
              label: 'Kebutuhan kalori harian (TDEE)',
              value: '${formatAngka(tdee, desimal: 0)} kkal',
              color: kSuccessColor,
            ),
          ],
        ],
      ),
    );
  }
}
