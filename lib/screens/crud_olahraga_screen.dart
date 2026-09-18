import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';
import '../utils/parsing.dart';

const String kTabelOlahraga = 'catatan_olahraga';

String _namaPengguna() {
  final String email = Supabase.instance.client.auth.currentUser?.email ?? 'pengguna';
  return email.split('@').first;
}

String _formatTanggal(DateTime tanggal) {
  const List<String> namaBulan = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  return '${tanggal.day} ${namaBulan[tanggal.month - 1]} ${tanggal.year}';
}

DateTime _uraiTanggal(dynamic nilai) {
  if (nilai == null) return DateTime.now();
  try {
    return DateTime.parse(nilai.toString());
  } catch (e) {
    return DateTime.now();
  }
}

class CrudOlahragaScreen extends StatefulWidget {
  const CrudOlahragaScreen({super.key});

  @override
  State<CrudOlahragaScreen> createState() => _CrudOlahragaScreenState();
}

class _CrudOlahragaScreenState extends State<CrudOlahragaScreen> {
  late final Stream<List<Map<String, dynamic>>> _streamCatatan;

  @override
  void initState() {
    super.initState();
    _streamCatatan = Supabase.instance.client
        .from(kTabelOlahraga)
        .stream(primaryKey: ['id'])
        .order('tanggal', ascending: false);
  }

  void _bukaFormTambahEdit({String? id, Map<String, dynamic>? dataAwal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FormOlahraga(id: id, dataAwal: dataAwal),
    );
  }

  void _konfirmasiHapus(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('DELETE LOG?', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        content: const Text('This exercise record will be permanently removed.', style: TextStyle(color: kTextMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: kTextMuted))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Supabase.instance.client.from(kTabelOlahraga).delete().eq('id', id);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: kWarningColor));
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: kWarningColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('EXERCISE LOG'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        elevation: 8,
        onPressed: () => _bukaFormTambahEdit(),
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _streamCatatan,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorBox(message: 'Connection Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          final List<Map<String, dynamic>> daftar = snapshot.data!;
          if (daftar.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center_rounded, size: 64, color: Colors.white10),
                  SizedBox(height: 16),
                  Text(
                    'NO RECORDS FOUND',
                    style: TextStyle(color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = daftar[index];
              final String id = data['id'].toString();
              final DateTime tanggal = _uraiTanggal(data['tanggal']);
              final String catatanTambahan = (data['catatan'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data['jenis_olahraga'] ?? '-'}'.toUpperCase(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${data['durasi_menit'] ?? 0} MIN  \u2022  ${data['kalori_terbakar'] ?? 0} KCAL',
                            style: const TextStyle(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTanggal(tanggal),
                            style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w600),
                          ),
                          if (catatanTambahan.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(catatanTambahan, style: const TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 22, color: kTextMuted),
                          onPressed: () => _bukaFormTambahEdit(id: id, dataAwal: data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 22, color: kWarningColor),
                          onPressed: () => _konfirmasiHapus(id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FormOlahraga extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? dataAwal;

  const _FormOlahraga({this.id, this.dataAwal});

  @override
  State<_FormOlahraga> createState() => _FormOlahragaState();
}

class _FormOlahragaState extends State<_FormOlahraga> {
  late final TextEditingController _jenisController;
  late final TextEditingController _durasiController;
  late final TextEditingController _kaloriController;
  late final TextEditingController _catatanController;
  late DateTime _tanggalDipilih;

  String? _errorMessage;
  bool _sedangSimpan = false;

  bool get _modeEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    final data = widget.dataAwal;
    _jenisController = TextEditingController(text: data?['jenis_olahraga']?.toString() ?? '');
    _durasiController = TextEditingController(text: data?['durasi_menit']?.toString() ?? '');
    _kaloriController = TextEditingController(text: data?['kalori_terbakar']?.toString() ?? '');
    _catatanController = TextEditingController(text: data?['catatan']?.toString() ?? '');
    _tanggalDipilih = data == null ? DateTime.now() : _uraiTanggal(data['tanggal']);
  }

  @override
  void dispose() {
    _jenisController.dispose();
    _durasiController.dispose();
    _kaloriController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: kPrimaryColor, onPrimary: Colors.black, surface: kSurfaceColor)),
        child: child!,
      ),
    );
    if (hasil != null) {
      setState(() => _tanggalDipilih = hasil);
    }
  }

  String _tanggalKeIso(DateTime tanggal) {
    return '${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.day.toString().padLeft(2, '0')}';
  }

  Future<void> _simpan() async {
    final String jenis = _jenisController.text.trim();
    final int? durasi = parseAngkaBulat(_durasiController.text);
    final int? kalori = parseAngkaBulat(_kaloriController.text);

    if (jenis.isEmpty || durasi == null || kalori == null) {
      setState(() => _errorMessage = 'Invalid input values.');
      return;
    }

    setState(() {
      _sedangSimpan = true;
      _errorMessage = null;
    });

    final Map<String, dynamic> dataDisimpan = {
      'jenis_olahraga': jenis,
      'durasi_menit': durasi,
      'kalori_terbakar': kalori,
      'tanggal': _tanggalKeIso(_tanggalDipilih),
      'catatan': _catatanController.text.trim(),
      'dibuat_oleh': _namaPengguna(),
    };

    try {
      final tabel = Supabase.instance.client.from(kTabelOlahraga);
      if (_modeEdit) {
        await tabel.update(dataDisimpan).eq('id', widget.id!);
      } else {
        await tabel.insert(dataDisimpan);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _sedangSimpan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 32),
              Text(
                _modeEdit ? 'EDIT ACTIVITY' : 'NEW ACTIVITY',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _jenisController,
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration('Exercise Type', prefixIcon: const Icon(Icons.directions_run_rounded)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durasiController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration('Duration (min)', prefixIcon: const Icon(Icons.timer_outlined)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _kaloriController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration('Calories', prefixIcon: const Icon(Icons.local_fire_department_outlined)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pilihTanggal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: kSurfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: kPrimaryColor),
                      const SizedBox(width: 16),
                      Text(_formatTanggal(_tanggalDipilih), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _catatanController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration('Notes (Optional)', prefixIcon: const Icon(Icons.notes_rounded)),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                ErrorBox(message: _errorMessage!),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _sedangSimpan ? null : _simpan,
                style: kPrimaryButtonStyle,
                child: _sedangSimpan
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                    : Text(_modeEdit ? 'SAVE CHANGES' : 'CREATE LOG'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
