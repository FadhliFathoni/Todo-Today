import 'aliases.dart';

/// Hasil parsing nominal: nilainya, span teks yang dipakai (untuk dibuang dari title),
/// dan flag found.
class AmountResult {
  final int amount;
  final bool found;

  /// Posisi (start, end) di teks input yang dianggap mewakili nominal.
  final int start;
  final int end;

  const AmountResult({
    required this.amount,
    required this.found,
    required this.start,
    required this.end,
  });

  static const empty = AmountResult(amount: 0, found: false, start: -1, end: -1);
}

/// Parse nominal dari teks yang sudah di-normalize.
///
/// Mendukung:
/// - "20000", "20.000" (sudah dinormalisasi jadi "20000")
/// - "20 ribu", "20rb" (sudah jadi "20 ribu" oleh normalizer)
/// - "5 juta", "1.5 juta", "1,5 juta"
/// - "1 miliar"
/// - "setengah juta", "seperempat juta"
/// - "dua puluh ribu", "lima juta"
AmountResult extractAmount(String text) {
  // 1. Coba pola "<digit> <unit>" atau "<digit>" telanjang.
  final digitUnitRegex = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(juta|miliar|milyar|ribu)?',
  );

  AmountResult best = AmountResult.empty;
  int bestPriority = -1;

  for (final m in digitUnitRegex.allMatches(text)) {
    final numStr = m.group(1)!.replaceAll(',', '.');
    final unit = m.group(2);
    final base = double.tryParse(numStr);
    if (base == null) continue;

    int multiplier = 1;
    int priority = 0; // angka telanjang prioritas paling rendah
    switch (unit) {
      case 'ribu':
        multiplier = 1000;
        priority = 2;
        break;
      case 'juta':
        multiplier = 1000000;
        priority = 3;
        break;
      case 'miliar':
      case 'milyar':
        multiplier = 1000000000;
        priority = 3;
        break;
      default:
        // angka telanjang: hanya dianggap nominal kalau >= 1000 atau >= 100
        // (untuk hindari konflik dengan "tanggal 1", "jam 8")
        if (base < 100) continue;
        priority = 1;
    }

    final value = (base * multiplier).round();
    if (value <= 0) continue;

    if (priority > bestPriority || (priority == bestPriority && value > best.amount)) {
      best = AmountResult(
        amount: value,
        found: true,
        start: m.start,
        end: m.end,
      );
      bestPriority = priority;
    }
  }

  // 2. Pola "setengah/seperempat <unit>"
  final fractionRegex =
      RegExp(r'(setengah|seperempat|seperdua)\s+(juta|ribu|miliar|milyar)');
  for (final m in fractionRegex.allMatches(text)) {
    final fracWord = m.group(1)!;
    final unit = m.group(2)!;
    final fraction = (fracWord == 'seperempat') ? 0.25 : 0.5;
    int multiplier;
    switch (unit) {
      case 'ribu':
        multiplier = 1000;
        break;
      case 'juta':
        multiplier = 1000000;
        break;
      case 'miliar':
      case 'milyar':
        multiplier = 1000000000;
        break;
      default:
        continue;
    }
    final value = (fraction * multiplier).round();
    if (3 > bestPriority || (3 == bestPriority && value > best.amount)) {
      best = AmountResult(amount: value, found: true, start: m.start, end: m.end);
      bestPriority = 3;
    }
  }

  // 3. Spelled-out: "dua puluh ribu", "lima juta", "seratus ribu"
  final spelled = _parseSpelledOut(text);
  if (spelled.found) {
    if (3 > bestPriority || (3 == bestPriority && spelled.amount > best.amount)) {
      best = spelled;
    }
  }

  return best;
}

/// Coba parse angka spelled-out (Bahasa Indonesia) di dalam `text`.
///
/// Strategi sederhana: scan token-per-token, kumpulkan kata angka berurutan,
/// hitung nilainya, lalu kalikan dengan unit (ribu/juta/miliar) bila ada.
AmountResult _parseSpelledOut(String text) {
  final tokens = text.split(' ');
  AmountResult best = AmountResult.empty;

  int i = 0;
  int charPos = 0;
  while (i < tokens.length) {
    final tok = tokens[i];
    if (_isNumberWord(tok)) {
      final startChar = charPos;
      int j = i;
      while (j < tokens.length && _isNumberOrUnit(tokens[j])) {
        j++;
      }
      final group = tokens.sublist(i, j);
      final value = _evaluateSpelledGroup(group);
      if (value > 0) {
        final endChar = startChar + group.join(' ').length;
        if (best.amount < value) {
          best = AmountResult(
            amount: value,
            found: true,
            start: startChar,
            end: endChar,
          );
        }
      }
      // advance
      for (int k = i; k < j; k++) {
        charPos += tokens[k].length + 1;
      }
      i = j;
    } else {
      charPos += tok.length + 1;
      i++;
    }
  }

  return best;
}

/// Hanya kata "angka" murni (mis. "dua", "tiga", "sepuluh", "sebelas"),
/// bukan kata satuan/multiplier. Spelled-out group HARUS dimulai dengan
/// salah satu kata ini untuk menghindari false positive dari "ribu" /
/// "juta" yang muncul karena sudah ditangani oleh path digit+unit.
bool _isNumberWord(String tok) {
  if (spelledNumberWords.containsKey(tok)) return true;
  const numberOnly = {'seratus', 'seribu', 'sejuta'};
  return numberOnly.contains(tok);
}

/// Setelah grup dimulai, token-token "puluh", "ratus", "ribu", "juta",
/// "belas", "miliar" boleh ikut.
bool _isNumberOrUnit(String tok) {
  if (_isNumberWord(tok)) return true;
  const units = {'belas', 'puluh', 'ratus', 'ribu', 'juta', 'miliar', 'milyar'};
  return units.contains(tok);
}

/// Evaluasi list token angka spelled-out, mis. ["dua","puluh","ribu"] → 20000
int _evaluateSpelledGroup(List<String> tokens) {
  int total = 0;
  int current = 0;

  for (int i = 0; i < tokens.length; i++) {
    final t = tokens[i];

    if (t == 'seribu') {
      current = (current == 0 ? 1 : current) * 1000;
      total += current;
      current = 0;
      continue;
    }
    if (t == 'seratus') {
      current = (current == 0 ? 1 : current) * 100;
      continue;
    }
    if (t == 'sejuta') {
      current = (current == 0 ? 1 : current) * 1000000;
      total += current;
      current = 0;
      continue;
    }

    if (t == 'belas') {
      // "dua belas", "tiga belas", ... — token sebelumnya sudah masuk current.
      current += 10;
      continue;
    }
    if (t == 'puluh') {
      current = current * 10;
      continue;
    }
    if (t == 'ratus') {
      current = (current == 0 ? 1 : current) * 100;
      continue;
    }
    if (t == 'ribu') {
      current = (current == 0 ? 1 : current) * 1000;
      total += current;
      current = 0;
      continue;
    }
    if (t == 'juta') {
      current = (current == 0 ? 1 : current) * 1000000;
      total += current;
      current = 0;
      continue;
    }
    if (t == 'miliar' || t == 'milyar') {
      current = (current == 0 ? 1 : current) * 1000000000;
      total += current;
      current = 0;
      continue;
    }

    final n = spelledNumberWords[t];
    if (n != null) {
      // sepuluh → 10, sebelas → 11
      if (t == 'sepuluh' || t == 'sebelas') {
        current += n;
      } else {
        current = current * 10 + n;
        // tapi kalau current jadi terlalu besar tidak masuk akal (mis. user bilang "satu lima"),
        // biarkan saja — orchestrator yang menilai confidence.
      }
    }
  }

  return total + current;
}
