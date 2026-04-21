import 'aliases.dart';

class CategoryMatch {
  final String category;
  final bool found;
  final bool ambiguous;
  final List<({int start, int end})> spans;

  const CategoryMatch({
    required this.category,
    required this.found,
    required this.ambiguous,
    required this.spans,
  });
}

class CategoryMatcher {
  /// `availableCategories` adalah daftar kategori user dari Firestore.
  CategoryMatcher({List<String> availableCategories = const []})
      : _categories = _mergeAliases(availableCategories);

  final Map<String, List<String>> _categories;

  static Map<String, List<String>> _mergeAliases(List<String> dynamicCategories) {
    final merged = <String, List<String>>{};
    defaultCategoryAliases.forEach((k, v) => merged[k] = List.of(v));
    for (final c in dynamicCategories) {
      final key = c.toLowerCase().trim();
      if (key.isEmpty) continue;
      merged.putIfAbsent(key, () => [key]);
      if (!merged[key]!.contains(key)) merged[key]!.add(key);
    }
    return merged;
  }

  CategoryMatch match(String text) {
    // Prioritas 1: pola eksplisit "kategori X"
    final explicit = RegExp(r'kategori\s+([a-z][a-z\s]*?)(?:\s+(?:dari|jam|tanggal)|$)')
        .firstMatch(text);
    if (explicit != null) {
      final raw = explicit.group(1)!.trim();
      // Coba cocokkan ke canonical
      for (final entry in _categories.entries) {
        for (final alias in entry.value) {
          if (raw.startsWith(alias) || raw == alias) {
            return CategoryMatch(
              category: entry.key,
              found: true,
              ambiguous: false,
              spans: [(start: explicit.start, end: explicit.end)],
            );
          }
        }
      }
      // Tidak ada di alias → pakai apa adanya
      return CategoryMatch(
        category: raw,
        found: true,
        ambiguous: false,
        spans: [(start: explicit.start, end: explicit.end)],
      );
    }

    // Prioritas 2: alias inline
    final hits = <String, ({int start, int end})>{};
    _categories.forEach((canonical, aliases) {
      for (final alias in aliases) {
        final m = RegExp('\\b' + RegExp.escape(alias) + '\\b').firstMatch(text);
        if (m != null) {
          hits.putIfAbsent(canonical, () => (start: m.start, end: m.end));
        }
      }
    });

    if (hits.isEmpty) {
      return const CategoryMatch(
        category: '',
        found: false,
        ambiguous: false,
        spans: [],
      );
    }

    final sorted = hits.entries.toList()
      ..sort((a, b) => a.value.start.compareTo(b.value.start));
    final picked = sorted.first;
    return CategoryMatch(
      category: picked.key,
      found: true,
      ambiguous: hits.length > 1,
      spans: hits.values.toList(),
    );
  }
}
