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
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${tanggal.day} ${namaBulan[tanggal.month - 1]} ${tanggal.year}';
}

// Kolom `tanggal` bertipe `date` di Postgres, dikirim/diterima sebagai
// teks "YYYY-MM-DD".
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
        title: const Text('Hapus catatan?'),
        content: const Text('Catatan olahraga ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Supabase.instance.client.from(kTabelOlahraga).delete().eq('id', id);
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: kWarningColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar('Catatan Aktivitas Olahraga'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentColor,
        onPressed: () => _bukaFormTambahEdit(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _streamCatatan,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ErrorBox(
                message: 'Gagal memuat data: ${snapshot.error}\n\n'
                    'Pastikan Supabase sudah di-setup (lihat SUPABASE_SETUP.md) '
                    'dan koneksi internet aktif.',
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Map<String, dynamic>> daftar = snapshot.data!;
          if (daftar.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada catatan olahraga.\nTekan tombol + untuk menambah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: daftar.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> data = daftar[index];
              final String id = data['id'].toString();
              final DateTime tanggal = _uraiTanggal(data['tanggal']);
              final String catatanTambahan = (data['catatan'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: kSuccessColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.fitness_center, color: kSuccessColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${data['jenis_olahraga'] ?? '-'}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(
                            '${data['durasi_menit'] ?? 0} menit  \u2022  ${data['kalori_terbakar'] ?? 0} kkal  \u2022  ${_formatTanggal(tanggal)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          if (catatanTambahan.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(catatanTambahan, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                          ],
                          const SizedBox(height: 4),
                          Text('oleh ${data['dibuat_oleh'] ?? '-'}', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: kPrimaryColor),
                          onPressed: () => _bukaFormTambahEdit(id: id, dataAwal: data),
                          tooltip: 'Ubah',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: kWarningColor),
                          onPressed: () => _konfirmasiHapus(id),
                          tooltip: 'Hapus',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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
    );
    if (hasil != null) {
      setState(() {
        _tanggalDipilih = hasil;
      });
    }
  }

  String _tanggalKeIso(DateTime tanggal) {
    final String bulan = tanggal.month.toString().padLeft(2, '0');
    final String hari = tanggal.day.toString().padLeft(2, '0');
    return '${tanggal.year}-$bulan-$hari';
  }

  Future<void> _simpan() async {
    final String jenis = _jenisController.text.trim();
    final int? durasi = parseAngkaBulat(_durasiController.text);
    final int? kalori = parseAngkaBulat(_kaloriController.text);

    if (jenis.isEmpty || durasi == null || kalori == null) {
      setState(() {
        _errorMessage = 'Jenis olahraga, durasi (menit), dan kalori terbakar wajib diisi dengan benar.';
      });
      return;
    }
    if (durasi <= 0 || kalori < 0) {
      setState(() {
        _errorMessage = 'Durasi harus lebih dari 0 dan kalori tidak boleh negatif.';
      });
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
        _errorMessage = 'Gagal menyimpan: $e';
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
          color: kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
              ),
              const SizedBox(height: 16),
              Text(
                _modeEdit ? 'Ubah Catatan Olahraga' : 'Tambah Catatan Olahraga',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kPrimaryDark),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jenisController,
                decoration: buildInputDecoration('Jenis olahraga', prefixIcon: const Icon(Icons.directions_run), hintText: 'Lari, renang, bersepeda, dll'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durasiController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration('Durasi (menit)', prefixIcon: const Icon(Icons.timer)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _kaloriController,
                keyboardType: TextInputType.number,
                decoration: buildInputDecoration('Kalori terbakar (kkal)', prefixIcon: const Icon(Icons.local_fire_department)),
              ),
              const SizedBox(height: 12),
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
                      Text(_formatTanggal(_tanggalDipilih)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _catatanController,
                maxLines: 2,
                decoration: buildInputDecoration('Catatan (opsional)', prefixIcon: const Icon(Icons.note)),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                ErrorBox(message: _errorMessage!),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _sedangSimpan ? null : _simpan,
                style: kPrimaryButtonStyle,
                child: _sedangSimpan
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text(_modeEdit ? 'Simpan Perubahan' : 'Tambah Catatan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
