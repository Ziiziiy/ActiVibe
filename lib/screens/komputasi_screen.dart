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
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('KOMPUTASI'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _TombolTab(label: 'BMI', aktif: _tabAktif == 0, onTap: () => setState(() => _tabAktif = 0))),
                  const SizedBox(width: 12),
                  Expanded(child: _TombolTab(label: 'KALORI', aktif: _tabAktif == 1, onTap: () => setState(() => _tabAktif = 1))),
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
    if (bmi < 18.5) return 'UNDERWEIGHT';
    if (bmi < 25) return 'NORMAL';
    if (bmi < 30) return 'OVERWEIGHT';
    return 'OBESITAS';
  }

  void _hitungBmi() {
    final double? berat = parseAngka(_beratController.text);
    final double? tinggiCm = parseAngka(_tinggiController.text);

    if (berat == null || tinggiCm == null) {
      setState(() {
        _errorMessage = 'Input tidak valid.';
        _bmi = null;
      });
      return;
    }
    if (berat <= 0 || tinggiCm <= 0) {
      setState(() {
        _errorMessage = 'Nilai harus > 0.';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _beratController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Berat (kg)', prefixIcon: const Icon(Icons.monitor_weight_outlined)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _tinggiController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Tinggi (cm)', prefixIcon: const Icon(Icons.height_rounded)),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            ErrorBox(message: _errorMessage!),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungBmi,
            style: kPrimaryButtonStyle,
            child: const Text('CALCULATE BMI'),
          ),
          if (bmi != null) ...[
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
                  const Text('YOUR BMI', style: TextStyle(fontSize: 12, color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Text(formatAngka(bmi, desimal: 1), style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: kPrimaryColor)),
                  const SizedBox(height: 8),
                  Text(_kategoriBmi(bmi), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                ],
              ),
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
    'Sangat jarang': 1.2,
    'Ringan (1-3x/minggu)': 1.375,
    'Sedang (3-5x/minggu)': 1.55,
    'Berat (6-7x/minggu)': 1.725,
    'Ekstrim (2x/hari)': 1.9,
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
        _errorMessage = 'Input tidak valid.';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('JENIS KELAMIN', style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('PRIA'),
                  selected: _jenisKelamin == 'Pria',
                  onSelected: (s) => setState(() => _jenisKelamin = 'Pria'),
                  selectedColor: kPrimaryColor,
                  labelStyle: TextStyle(color: _jenisKelamin == 'Pria' ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('WANITA'),
                  selected: _jenisKelamin == 'Wanita',
                  onSelected: (s) => setState(() => _jenisKelamin = 'Wanita'),
                  selectedColor: kPrimaryColor,
                  labelStyle: TextStyle(color: _jenisKelamin == 'Wanita' ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _beratController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Berat (kg)', prefixIcon: const Icon(Icons.monitor_weight_outlined)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _tinggiController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: buildInputDecoration('Tinggi (cm)', prefixIcon: const Icon(Icons.height_rounded)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _usiaController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: buildInputDecoration('Usia', prefixIcon: const Icon(Icons.cake_outlined)),
          ),
          const SizedBox(height: 24),
          const Text('AKTIVITAS', style: TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<double>(
                value: _faktorAktivitas,
                dropdownColor: kSurfaceColor,
                isExpanded: true,
                items: _pilihanAktivitas.entries
                    .map((e) => DropdownMenuItem<double>(
                          value: e.value,
                          child: Text(e.key, style: const TextStyle(fontSize: 14, color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _faktorAktivitas = v ?? 1.2),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            ErrorBox(message: _errorMessage!),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _hitungKalori,
            style: kPrimaryButtonStyle,
            child: const Text('HITUNG KALORI'),
          ),
          if (tdee != null) ...[
            const SizedBox(height: 32),
            InfoCard(
              label: 'KEBUTUHAN KALORI HARIAN',
              value: '${formatAngka(tdee, desimal: 0)} KKAL',
              color: kPrimaryColor,
            ),
          ],
        ],
      ),
    );
  }
}
