double? parseAngka(String teks) {
  String bersih = teks.trim().replaceAll(' ', '');
  if (bersih.isEmpty) return null;
  if (bersih.contains(',') && !bersih.contains('.')) {
    bersih = bersih.replaceAll(',', '.');
  }
  return double.tryParse(bersih);
}

int? parseAngkaBulat(String teks) {
  final String bersih = teks.trim().replaceAll(' ', '');
  if (bersih.isEmpty) return null;
  return int.tryParse(bersih);
}

String formatAngka(double nilai, {int desimal = 1}) {
  if (nilai.isNaN) return '-';
  if (nilai == nilai.truncateToDouble()) {
    return nilai.toStringAsFixed(0);
  }
  return nilai.toStringAsFixed(desimal);
}
