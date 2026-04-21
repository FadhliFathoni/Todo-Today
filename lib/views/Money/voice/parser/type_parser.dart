import 'aliases.dart';

class TypeResult {
  final String type; // 'income' | 'expense'
  final bool explicit;
  final List<({int start, int end})> spans;

  const TypeResult({
    required this.type,
    required this.explicit,
    required this.spans,
  });
}

/// Deteksi type transaksi (income / expense) berdasarkan keyword.
///
/// Default: expense (mayoritas catatan harian adalah pengeluaran).
TypeResult extractType(String text) {
  final spans = <({int start, int end})>[];
  bool hasIncome = false;
  bool hasExpense = false;

  for (final kw in incomeKeywords) {
    final idx = _wordIndex(text, kw);
    if (idx != -1) {
      hasIncome = true;
      spans.add((start: idx, end: idx + kw.length));
    }
  }
  for (final kw in expenseKeywords) {
    final idx = _wordIndex(text, kw);
    if (idx != -1) {
      hasExpense = true;
      spans.add((start: idx, end: idx + kw.length));
    }
  }

  if (hasIncome && !hasExpense) {
    return TypeResult(type: 'income', explicit: true, spans: spans);
  }
  if (hasExpense && !hasIncome) {
    return TypeResult(type: 'expense', explicit: true, spans: spans);
  }
  if (hasIncome && hasExpense) {
    // Ambiguous, prioritaskan income kalau ada keyword strong seperti gaji/bonus
    final strongIncome = ['gaji', 'bonus', 'thr', 'refund'];
    if (strongIncome.any((k) => _wordIndex(text, k) != -1)) {
      return TypeResult(type: 'income', explicit: true, spans: spans);
    }
    return TypeResult(type: 'expense', explicit: true, spans: spans);
  }

  return const TypeResult(type: 'expense', explicit: false, spans: []);
}

int _wordIndex(String text, String word) {
  final m = RegExp('\\b' + RegExp.escape(word) + '\\b').firstMatch(text);
  return m?.start ?? -1;
}
