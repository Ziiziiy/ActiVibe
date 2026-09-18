// =======================================================================
// HALAMAN STOPWATCH
// =======================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../widgets/shared_widgets.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _daftarLap = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _mulaiAtauJeda() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    _timer?.cancel();
    _stopwatch.reset();
    setState(() {
      _daftarLap.clear();
    });
  }

  void _catatLap() {
    setState(() {
      _daftarLap.insert(0, _stopwatch.elapsed);
    });
  }

  String _formatDurasi(Duration d) {
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    String tigaDigit(int n) => n.toString().padLeft(3, '0');
    final String jam = duaDigit(d.inHours);
    final String menit = duaDigit(d.inMinutes.remainder(60));
    final String detik = duaDigit(d.inSeconds.remainder(60));
    final String ms = tigaDigit(d.inMilliseconds.remainder(1000));
    return '$jam:$menit:$detik.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final bool berjalan = _stopwatch.isRunning;

    return Scaffold(
      appBar: buildAppBar('Stopwatch'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              _formatDurasi(_stopwatch.elapsed),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kPrimaryDark, fontFeatures: [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _mulaiAtauJeda,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: berjalan ? kWarningColor : kSuccessColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(berjalan ? 'Jeda' : 'Mulai', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                OutlinedButton(
                  onPressed: berjalan ? _catatLap : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kTextMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _daftarLap.isEmpty
                  ? Center(
                      child: Text('Belum ada catatan lap', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _daftarLap.length,
                      itemBuilder: (context, index) {
                        final int nomorLap = _daftarLap.length - index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Lap $nomorLap', style: const TextStyle(fontSize: 13, color: kTextMuted)),
                              Text(_formatDurasi(_daftarLap[index]), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
