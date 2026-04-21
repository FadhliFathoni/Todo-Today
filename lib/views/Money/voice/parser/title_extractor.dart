import 'aliases.dart';

/// Ekstrak judul/deskripsi dari teks normalized dengan membuang token-token
/// yang sudah ditangani extractor lain (amount, datetime, type, wallet, category).
String extractTitle({
  required String normalizedText,
  required List<({int start, int end})> consumedSpans,
}) {
  if (normalizedText.isEmpty) return '';

  // Bangun string baru, skip karakter yang ada di dalam consumedSpans.
  final buf = StringBuffer();
  final spans = [...consumedSpans]
    ..sort((a, b) => a.start.compareTo(b.start));

  int cursor = 0;
  for (final s in spans) {
    if (s.start < 0) continue;
    if (s.start > cursor) {
      buf.write(normalizedText.substring(cursor, s.start));
    }
    cursor = s.end > cursor ? s.end : cursor;
  }
  if (cursor < normalizedText.length) {
    buf.write(normalizedText.substring(cursor));
  }

  var leftover = buf.toString();

  // Buang konektor & preposisi umum.
  const stopWords = {
    'dari',
    'di',
    'untuk',
    'buat',
    'ke',
    'dengan',
    'pakai',
    'pake',
    'sama',
    'kategori',
    'wallet',
    'dompet',
    'senilai',
    'sebesar',
    'sebanyak',
    'sejumlah',
    'yang',
    'dan',
    'atau',
    'tadi',
    'saja',
  };

  // Buang juga keyword tipe yang mungkin masih nyangkut.
  final allTypeKw = {...expenseKeywords, ...incomeKeywords};

  final tokens = leftover
      .split(RegExp(r'\s+'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .where((t) => !stopWords.contains(t))
      .where((t) => !allTypeKw.contains(t))
      .toList();

  // Ambil maksimal 5 token pertama supaya title tidak panjang.
  final picked = tokens.take(5).join(' ');
  return picked.trim();
}
