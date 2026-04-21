import 'aliases.dart';

class WalletMatch {
  final String wallet;
  final bool found;
  final bool ambiguous;
  final List<({int start, int end})> spans;

  const WalletMatch({
    required this.wallet,
    required this.found,
    required this.ambiguous,
    required this.spans,
  });
}

class WalletMatcher {
  /// `availableWallets` adalah list nama wallet yang user punya
  /// (mis. dari `finance/{user}/wallet` Firestore). Semua dianggap lowercase.
  /// Jika kosong, hanya alias built-in yang dipakai.
  WalletMatcher({List<String> availableWallets = const []})
      : _wallets = _mergeAliases(availableWallets);

  final Map<String, List<String>> _wallets;

  static Map<String, List<String>> _mergeAliases(List<String> dynamicWallets) {
    final merged = <String, List<String>>{};
    defaultWalletAliases.forEach((k, v) => merged[k] = List.of(v));
    for (final w in dynamicWallets) {
      final key = w.toLowerCase().trim();
      if (key.isEmpty) continue;
      merged.putIfAbsent(key, () => [key]);
      if (!merged[key]!.contains(key)) merged[key]!.add(key);
    }
    return merged;
  }

  /// Cari wallet pertama yang muncul. Jika lebih dari satu kandidat
  /// match (bukan dari group/alias yang sama) → tandai ambiguous.
  WalletMatch match(String text) {
    final hits = <String, ({int start, int end})>{};

    _wallets.forEach((canonical, aliases) {
      for (final alias in aliases) {
        final m = RegExp('\\b' + RegExp.escape(alias) + '\\b').firstMatch(text);
        if (m != null) {
          // simpan hit pertama per canonical
          hits.putIfAbsent(
            canonical,
            () => (start: m.start, end: m.end),
          );
        }
      }
    });

    if (hits.isEmpty) {
      return const WalletMatch(
        wallet: '',
        found: false,
        ambiguous: false,
        spans: [],
      );
    }

    // Ambil yang paling awal posisinya.
    final sorted = hits.entries.toList()
      ..sort((a, b) => a.value.start.compareTo(b.value.start));
    final picked = sorted.first;
    return WalletMatch(
      wallet: picked.key,
      found: true,
      ambiguous: hits.length > 1,
      spans: hits.values.toList(),
    );
  }
}
