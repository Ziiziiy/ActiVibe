// =======================================================================
// UTILITAS PARSING & FORMAT ANGKA
// Dipakai bersama supaya semua halaman menangani input angka secara
// konsisten (mendukung desimal, koma ala Indonesia, dan pesan error
// yang jelas untuk input yang tidak valid).
// =======================================================================

// Mengubah teks menjadi angka (double). Menerima "12.5" atau "12,5".
// Mengembalikan null kalau bukan angka yang valid.
double? parseAngka(String teks) {
  String bersih = teks.trim().replaceAll(' ', '');
  if (bersih.isEmpty) return null;
  if (bersih.contains(',') && !bersih.contains('.')) {
    bersih = bersih.replaceAll(',', '.');
  }
  return double.tryParse(bersih);
}

// Mengubah teks menjadi bilangan bulat (int). Mengembalikan null kalau
// bukan bilangan bulat yang valid.
int? parseAngkaBulat(String teks) {
  final String bersih = teks.trim().replaceAll(' ', '');
  if (bersih.isEmpty) return null;
  return int.tryParse(bersih);
}

// Memformat angka: bilangan bulat tanpa ".0" yang tidak perlu, bilangan
// berkoma tetap tampil dengan desimalnya (maksimal 1-2 angka di belakang
// koma supaya rapi dibaca).
String formatAngka(double nilai, {int desimal = 1}) {
  if (nilai.isNaN) return '-';
  if (nilai == nilai.truncateToDouble()) {
    return nilai.toStringAsFixed(0);
  }
  return nilai.toStringAsFixed(desimal);
}
