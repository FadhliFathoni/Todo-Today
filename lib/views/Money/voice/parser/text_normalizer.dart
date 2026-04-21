import 'aliases.dart';

/// Normalisasi teks STT mentah menjadi bentuk yang konsisten untuk extractor.
///
/// Operasi:
/// 1. lowercase + trim
/// 2. ganti tanda baca yang tidak penting jadi spasi (kecuali titik & koma di angka)
/// 3. expand singkatan: "rb" → "ribu", "jt" → "juta", "rp" dihapus, "20k" → "20 ribu"
/// 4. buang filler word ("dong", "ya", ...)
/// 5. rapikan whitespace
String normalizeText(String input) {
  var text = input.toLowerCase().trim();

  // Hapus simbol mata uang.
  text = text.replaceAll(RegExp(r'rp\.?\s*'), '');

  // "20k", "20K" → "20 ribu". Hanya jika `k` benar-benar sufiks angka.
  text = text.replaceAllMapped(
    RegExp(r'(\d+)\s*k\b'),
    (m) => '${m.group(1)} ribu',
  );

  // Singkatan unit nominal.
  text = text.replaceAllMapped(
    RegExp(r'(\d+)\s*rb\b'),
    (m) => '${m.group(1)} ribu',
  );
  text = text.replaceAllMapped(
    RegExp(r'(\d+)\s*jt\b'),
    (m) => '${m.group(1)} juta',
  );
  text = text.replaceAllMapped(
    RegExp(r'(\d+)\s*m\b'),
    (m) => '${m.group(1)} miliar',
  );

  // Singkatan tanggal.
  text = text.replaceAll(RegExp(r'\btgl\b'), 'tanggal');
  text = text.replaceAll(RegExp(r'\bjm\b'), 'jam');

  // Normalisasi pemisah ribuan & desimal hanya kalau di dalam digit.
  // (Kita pertahankan titik di dalam "20.000" tapi buang yang lain.)
  text = text.replaceAllMapped(
    RegExp(r'(\d)[.,](\d{3})(?!\d)'),
    (m) => '${m.group(1)}${m.group(2)}',
  );

  // Ganti tanda baca lain dengan spasi.
  text = text.replaceAll(RegExp(r'''[!?,;:\-\(\)\[\]"']'''), ' ');

  // Buang filler word.
  for (final filler in fillerWords) {
    text = text.replaceAll(RegExp('\\b$filler\\b'), ' ');
  }

  // Rapikan whitespace.
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  return text;
}
