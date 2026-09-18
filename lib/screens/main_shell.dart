import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'home_menu_screen.dart';
import 'stopwatch_screen.dart';
import 'bantuan_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indexAktif = 0;

  static const List<Widget> _halaman = [
    HomeMenuScreen(),
    StopwatchScreen(),
    BantuanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indexAktif, children: _halaman),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexAktif,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _indexAktif = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Halaman Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Stopwatch'),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Bantuan'),
        ],
      ),
    );
  }
}
