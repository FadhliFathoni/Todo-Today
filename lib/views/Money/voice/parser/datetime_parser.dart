import 'aliases.dart';

class DateTimeResult {
  final DateTime dateTime;
  final bool dateExplicit;
  final bool timeExplicit;
  final List<({int start, int end})> spans;

  const DateTimeResult({
    required this.dateTime,
    required this.dateExplicit,
    required this.timeExplicit,
    required this.spans,
  });
}

/// Map nama bulan Indonesia (lowercase) ke nomor.
const Map<String, int> _monthNames = {
  'januari': 1,
  'jan': 1,
  'februari': 2,
  'feb': 2,
  'maret': 3,
  'mar': 3,
  'april': 4,
  'apr': 4,
  'mei': 5,
  'juni': 6,
  'jun': 6,
  'juli': 7,
  'jul': 7,
  'agustus': 8,
  'agu': 8,
  'agt': 8,
  'september': 9,
  'sep': 9,
  'oktober': 10,
  'okt': 10,
  'november': 11,
  'nov': 11,
  'desember': 12,
  'des': 12,
};

/// Parse tanggal & waktu dari teks normalized.
/// `now` di-inject untuk testabilitas.
DateTimeResult extractDateTime(String text, {DateTime? now}) {
  now ??= DateTime.now();

  DateTime base = DateTime(now.year, now.month, now.day);
  bool dateExplicit = false;
  bool timeExplicit = false;
  int hour = now.hour;
  int minute = now.minute;
  final List<({int start, int end})> spans = [];

  // Relative day words
  final relativeMatchers = <String, int>{
    'hari ini': 0,
    'hri ini': 0,
    'sekarang': 0,
    'kemarin': -1,
    'kemaren': -1,
    'besok': 1,
    'besuk': 1,
    'lusa': 2,
  };
  for (final entry in relativeMatchers.entries) {
    final idx = text.indexOf(entry.key);
    if (idx != -1) {
      base = base.add(Duration(days: entry.value));
      dateExplicit = true;
      spans.add((start: idx, end: idx + entry.key.length));
      break;
    }
  }

  // "<n> hari yang lalu" / "<n> hari lalu"
  final daysAgo = RegExp(r'(\d+)\s+hari\s+(yang\s+)?lalu').firstMatch(text);
  if (daysAgo != null) {
    final n = int.tryParse(daysAgo.group(1)!) ?? 0;
    base = base.subtract(Duration(days: n));
    dateExplicit = true;
    spans.add((start: daysAgo.start, end: daysAgo.end));
  }

  // "tanggal X" (opsional bulan setelahnya)
  final tanggalMatch =
      RegExp(r'tanggal\s+(\d{1,2})(?:\s+([a-z]+))?').firstMatch(text);
  if (tanggalMatch != null) {
    final day = int.tryParse(tanggalMatch.group(1)!) ?? base.day;
    int month = base.month;
    int year = base.year;
    final monthName = tanggalMatch.group(2);
    if (monthName != null && _monthNames.containsKey(monthName)) {
      month = _monthNames[monthName]!;
    }
    // Jika tanggal di bulan ini sudah lewat dan user tidak menyebut bulan,
    // tetap pakai bulan ini (asumsi user mencatat hari ini / nanti).
    base = DateTime(year, month, day);
    dateExplicit = true;
    spans.add((start: tanggalMatch.start, end: tanggalMatch.end));
  } else {
    // Pola "X januari" tanpa kata "tanggal"
    final dayMonth = RegExp(r'\b(\d{1,2})\s+(' + _monthNames.keys.join('|') + r')\b')
        .firstMatch(text);
    if (dayMonth != null) {
      final day = int.tryParse(dayMonth.group(1)!) ?? base.day;
      final month = _monthNames[dayMonth.group(2)!]!;
      base = DateTime(base.year, month, day);
      dateExplicit = true;
      spans.add((start: dayMonth.start, end: dayMonth.end));
    }
  }

  // Jam: "jam 8", "jam 8 pagi", "jam 8.30", "jam 20"
  final jamMatch = RegExp(
          r'jam\s+(\d{1,2})(?:[.:](\d{2}))?(?:\s+(pagi|siang|sore|petang|malam|subuh))?')
      .firstMatch(text);
  if (jamMatch != null) {
    int h = int.tryParse(jamMatch.group(1)!) ?? hour;
    final m = int.tryParse(jamMatch.group(2) ?? '') ?? 0;
    final part = jamMatch.group(3);
    h = _adjustHourByDayPart(h, part);
    if (h >= 0 && h <= 23 && m >= 0 && m <= 59) {
      hour = h;
      minute = m;
      timeExplicit = true;
      spans.add((start: jamMatch.start, end: jamMatch.end));
    }
  } else {
    // Hanya day part tanpa jam eksplisit
    for (final entry in dayPartDefaultHour.entries) {
      final idx = text.indexOf(entry.key);
      if (idx != -1) {
        hour = entry.value;
        minute = 0;
        timeExplicit = true;
        spans.add((start: idx, end: idx + entry.key.length));
        break;
      }
    }
  }

  final result = DateTime(base.year, base.month, base.day, hour, minute);
  return DateTimeResult(
    dateTime: result,
    dateExplicit: dateExplicit,
    timeExplicit: timeExplicit,
    spans: spans,
  );
}

int _adjustHourByDayPart(int h, String? part) {
  if (part == null) return h;
  switch (part) {
    case 'subuh':
    case 'pagi':
      // 1..11 → tetap, 12 pagi → 0
      if (h == 12) return 0;
      return h;
    case 'siang':
      // 12..14: tetap, 1..3 → +12
      if (h >= 1 && h <= 4) return h + 12;
      return h;
    case 'sore':
    case 'petang':
      if (h >= 1 && h <= 6) return h + 12;
      return h;
    case 'malam':
      if (h >= 1 && h <= 11) return h + 12;
      return h;
  }
  return h;
}
