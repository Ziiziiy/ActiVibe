import 'dart:async';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

/// Menampilkan stopwatch, kontrol waktu, dan daftar durasi lap.
class StopwatchScreen extends StatefulWidget {
  /// Membuat halaman stopwatch.
  const StopwatchScreen({super.key});

  /// Membuat state yang menyimpan waktu dan status stopwatch.
  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

/// Mengelola waktu berjalan, jeda, reset, dan pencatatan durasi lap.
class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Duration _elapsed = Duration.zero;
  Duration _lastLap = Duration.zero;
  bool _isRunning = false;
  Timer? _timer;
  final List<Duration> _daftarLap = [];

  /// Menghentikan timer ketika layar dilepas agar tidak terjadi kebocoran timer.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Memulai stopwatch jika berhenti dan mengabaikan permintaan start ganda.
  void _mulaiTimer() {
    if (_isRunning) return;

    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });

    setState(() {
      _isRunning = true;
    });
  }

  /// Menghentikan timer tanpa menghapus waktu yang sudah tercatat.
  void _jedaTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;

    setState(() {
      _elapsed = _stopwatch.elapsed;
      _isRunning = false;
    });
  }

  /// Mengembalikan waktu dan seluruh daftar lap ke kondisi awal.
  void _reset() {
    _jedaTimer();
    _stopwatch.reset();

    setState(() {
      _elapsed = Duration.zero;
      _lastLap = Duration.zero;
      _daftarLap.clear();
    });
  }

  /// Menyimpan selisih waktu sejak lap terakhir sebagai durasi lap baru.
  void _catatLap() {
    if (_elapsed == _lastLap) return;

    setState(() {
      _daftarLap.insert(0, _elapsed - _lastLap);
      _lastLap = _elapsed;
    });
  }

  /// Memformat durasi menjadi jam, menit, detik, dan sentidetik.
  String _formatDurasi(Duration d) {
    final int totalMilidetik = d.inMilliseconds;
    final String menit = ((totalMilidetik ~/ 60000) % 60).toString().padLeft(2, '0');
    final String detik = ((totalMilidetik ~/ 1000) % 60).toString().padLeft(2, '0');
    final String sentidetik = ((totalMilidetik % 1000) ~/ 10).toString().padLeft(2, '0');

    if (totalMilidetik < 60 * 60 * 1000) {
      return '$menit:$detik,$sentidetik';
    }

    final String jam = (totalMilidetik ~/ (60 * 60 * 1000)).toString().padLeft(2, '0');
    return '$jam:$menit:$detik,$sentidetik';
  }

  /// Membangun tampilan stopwatch tanpa mengubah susunan kontrol yang ada.
  @override
  Widget build(BuildContext context) {
    final bool berjalan = _isRunning;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: buildAppBar('STOPWATCH'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Minimalist Timer Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                _formatDurasi(_elapsed),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: kPrimaryColor,
                  letterSpacing: 2,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start/Pause Button
                _ControlCircleButton(
                  onTap: berjalan ? _jedaTimer : _mulaiTimer,
                  icon: berjalan ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: berjalan ? kWarningColor : kPrimaryColor,
                  isFilled: true,
                ),
                const SizedBox(width: 24),
                // Lap Button
                _ControlCircleButton(
                  onTap: berjalan ? _catatLap : null,
                  icon: Icons.flag_rounded,
                  color: Colors.white,
                  isFilled: false,
                ),
                const SizedBox(width: 24),
                // Reset Button
                _ControlCircleButton(
                  onTap: _reset,
                  icon: Icons.refresh_rounded,
                  color: kTextMuted,
                  isFilled: false,
                ),
              ],
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                ),
                child: _daftarLap.isEmpty
                    ? const Center(
                        child: Text('NO LAPS RECORDED', style: TextStyle(color: kTextMuted, letterSpacing: 1, fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(32),
                        itemCount: _daftarLap.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 32),
                        itemBuilder: (context, index) {
                          final int nomorLap = _daftarLap.length - index;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LAP ${nomorLap.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kTextMuted, letterSpacing: 1),
                              ),
                              Text(
                                _formatDurasi(_daftarLap[index]),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color color;
  final bool isFilled;

  /// Membuat tombol kontrol berbentuk lingkaran.
  const _ControlCircleButton({this.onTap, required this.icon, required this.color, required this.isFilled});

  /// Menggambar tombol dengan gaya isi atau outline sesuai konfigurasi.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: isFilled ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: isFilled ? null : Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: isFilled ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))] : null,
        ),
        child: Icon(icon, color: isFilled ? Colors.black : color, size: 30),
      ),
    );
  }
}
