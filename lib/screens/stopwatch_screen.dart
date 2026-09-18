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
    final String ms = tigaDigit(d.inMilliseconds.remainder(1000) ~/ 10);
    return '$jam:$menit:$detik.$ms';
  }

  @override
  Widget build(BuildContext context) {
    final bool berjalan = _stopwatch.isRunning;

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
                _formatDurasi(_stopwatch.elapsed),
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
                  onTap: _mulaiAtauJeda,
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

  const _ControlCircleButton({this.onTap, required this.icon, required this.color, required this.isFilled});

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
