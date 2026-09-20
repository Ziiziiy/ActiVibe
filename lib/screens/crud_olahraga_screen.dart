import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';
import '../utils/parsing.dart';

const String kTabelOlahraga = 'catatan_olahraga';

// ignore: unused_element
String _emailPengguna() {
  return Supabase.instance.client.auth.currentUser?.email ?? '';
}

String _formatTanggal(DateTime tanggal) {
  const List<String> namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
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
  List<Map<String, dynamic>> _daftarCatatan = [];
  bool _sedangMemuat = true;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  // Fungsi memuat data secara langsung dari Supabase
  Future<void> _muatData() async {
    try {
      final String userEmail = _emailPengguna();
      final response = await Supabase.instance.client
          .from(kTabelOlahraga)
          .select()
          .eq('dibuat_oleh', userEmail)
          .order('tanggal', ascending: false);

      if (mounted) {
        setState(() {
          _daftarCatatan = List<Map<String, dynamic>>.from(response);
          _sedangMemuat = false;
          _pesanError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pesanError = 'Gagal memuat data: $e';
          _sedangMemuat = false;
        });
      }
    }
  }

  // Menunggu kembalian bernilai true dari form untuk langsung me-refresh list
  Future<void> _bukaFormTambahEdit({String? id, Map<String, dynamic>? dataAwal}) async {
    final bool? berhasil = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FormOlahraga(id: id, dataAwal: dataAwal),
    );

    if (berhasil == true) {
      _muatData();
    }
  }

  void _konfirmasiHapus(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'HAPUS CATATAN?',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
        ),
        content: const Text(
          'Catatan olahraga ini akan dihapus secara permanen.',
          style: TextStyle(color: kTextMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                // Hapus data dari Supabase
                await Supabase.instance.client.from(kTabelOlahraga).delete().eq('id', id);

                // Langsung perbarui tampilan seketika tanpa reload layar
                if (mounted) {
                  setState(() {
                    _daftarCatatan.removeWhere((item) => item['id'].toString() == id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Catatan berhasil dihapus'),
                      backgroundColor: kPrimaryColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: kWarningColor,
                    ),
                  );
                }
              }
            },
            child: const Text('HAPUS', style: TextStyle(color: kWarningColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('CATATAN OLAHRAGA'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        elevation: 8,
        onPressed: () => _bukaFormTambahEdit(),
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
      ),
      body: RefreshIndicator(
        color: kPrimaryColor,
        backgroundColor: kSurfaceColor,
        onRefresh: _muatData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_sedangMemuat) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (_pesanError != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ErrorBox(message: _pesanError!),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: _muatData,
              icon: const Icon(Icons.refresh, color: kPrimaryColor),
              label: const Text('Coba Lagi', style: TextStyle(color: kPrimaryColor)),
            ),
          ),
        ],
      );
    }

    if (_daftarCatatan.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center_rounded, size: 64, color: Colors.white10),
                SizedBox(height: 16),
                Text(
                  'BELUM ADA CATATAN',
                  style: TextStyle(color: kTextMuted, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Tekan tombol + untuk menambah aktivitas olahraga',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      itemCount: _daftarCatatan.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> data = _daftarCatatan[index];
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
                      '${data['durasi_menit'] ?? 0} MENIT   •   ${data['kalori_terbakar'] ?? 0} KKAL',
                      style: const TextStyle(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTanggal(tanggal),
                      style: const TextStyle(fontSize: 11, color: kTextMuted, fontWeight: FontWeight.w600),
                    ),
                    if (catatanTambahan.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        catatanTambahan,
                        style: const TextStyle(fontSize: 12, color: Colors.white54, fontStyle: FontStyle.italic),
                      ),
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
      setState(() => _errorMessage = 'Mohon lengkapi semua kolom dengan benar.');
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
      'dibuat_oleh': _emailPengguna(), // Mengirimkan email lengkap
    };

    try {
      final tabel = Supabase.instance.client.from(kTabelOlahraga);
      if (_modeEdit) {
        await tabel.update(dataDisimpan).eq('id', widget.id!);
      } else {
        await tabel.insert(dataDisimpan);
      }
      
      // Mengirim sinyal balik (true) ke halaman utama agar data langsung dimuat ulang
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menyimpan data: $e';
          _sedangSimpan = false;
        });
      }
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
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _modeEdit ? 'EDIT AKTIVITAS' : 'TAMBAH AKTIVITAS',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _jenisController,
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration(
                  'Jenis Olahraga (misal: Lari, Renang)',
                  prefixIcon: const Icon(Icons.directions_run_rounded),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durasiController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration(
                        'Durasi (menit)',
                        prefixIcon: const Icon(Icons.timer_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _kaloriController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration(
                        'Kalori (kkal)',
                        prefixIcon: const Icon(Icons.local_fire_department_outlined),
                      ),
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
                        _formatTanggal(_tanggalDipilih),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text('Ubah', style: TextStyle(color: kPrimaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _catatanController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration(
                  'Catatan (Opsional)',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                      )
                    : Text(_modeEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH CATATAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}