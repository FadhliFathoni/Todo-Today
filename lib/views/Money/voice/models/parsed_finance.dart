/// Hasil parsing satu utterance suara menjadi data transaksi terstruktur.
///
/// `type` selalu salah satu dari `income` / `expense`.
/// Saat disimpan ke Firestore, mapping ke string yang sudah dipakai project
/// (`Pemasukan` / `Pengeluaran`) dilakukan di `toFirestoreType()`.
class ParsedFinance {
  final String type; // "income" | "expense"
  final String title;
  final int amount;
  final DateTime dateTime;
  final String wallet;
  final String category;

  /// 0.0 - 1.0
  final double confidence;

  /// Field yang tidak ditemukan di kalimat (diisi default).
  final List<String> missingFields;

  /// True jika ada interpretasi ganda (mis. dua wallet sama-sama match).
  final bool ambiguous;

  /// Teks asli (raw STT result) dan teks setelah normalisasi.
  final String rawText;
  final String normalizedText;

  const ParsedFinance({
    required this.type,
    required this.title,
    required this.amount,
    required this.dateTime,
    required this.wallet,
    required this.category,
    required this.confidence,
    required this.missingFields,
    required this.ambiguous,
    required this.rawText,
    required this.normalizedText,
  });

  String get firestoreType => type == 'income' ? 'Pemasukan' : 'Pengeluaran';

  ParsedFinance copyWith({
    String? type,
    String? title,
    int? amount,
    DateTime? dateTime,
    String? wallet,
    String? category,
    double? confidence,
    List<String>? missingFields,
    bool? ambiguous,
  }) {
    return ParsedFinance(
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dateTime: dateTime ?? this.dateTime,
      wallet: wallet ?? this.wallet,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      missingFields: missingFields ?? this.missingFields,
      ambiguous: ambiguous ?? this.ambiguous,
      rawText: rawText,
      normalizedText: normalizedText,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'amount': amount,
        'dateTime': dateTime.toIso8601String(),
        'wallet': wallet,
        'category': category,
        'confidence': confidence,
        'missingFields': missingFields,
        'ambiguous': ambiguous,
        'rawText': rawText,
        'normalizedText': normalizedText,
      };

  @override
  String toString() => toMap().toString();
}
