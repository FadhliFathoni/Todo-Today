import '../models/parsed_finance.dart';
import 'aliases.dart';
import 'amount_parser.dart';
import 'category_matcher.dart';
import 'datetime_parser.dart';
import 'text_normalizer.dart';
import 'title_extractor.dart';
import 'type_parser.dart';
import 'wallet_matcher.dart';

/// Orchestrator: gabungkan semua extractor menjadi `ParsedFinance`.
class FinanceVoiceParser {
  FinanceVoiceParser({
    List<String> availableWallets = const [],
    List<String> availableCategories = const [],
  })  : _walletMatcher = WalletMatcher(availableWallets: availableWallets),
        _categoryMatcher = CategoryMatcher(availableCategories: availableCategories);

  final WalletMatcher _walletMatcher;
  final CategoryMatcher _categoryMatcher;

  ParsedFinance parse(String rawText, {DateTime? now}) {
    final normalized = normalizeText(rawText);
    final missing = <String>[];

    final typeRes = extractType(normalized);
    final amountRes = extractAmount(normalized);
    final dtRes = extractDateTime(normalized, now: now);
    final walletRes = _walletMatcher.match(normalized);
    final categoryRes = _categoryMatcher.match(normalized);

    final consumed = <({int start, int end})>[
      ...typeRes.spans,
      if (amountRes.found) (start: amountRes.start, end: amountRes.end),
      ...dtRes.spans,
      ...walletRes.spans,
      ...categoryRes.spans,
    ];
    final title = extractTitle(
      normalizedText: normalized,
      consumedSpans: consumed,
    );

    final type = typeRes.type;

    final wallet = walletRes.found ? walletRes.wallet : FinanceDefaults.wallet;
    if (!walletRes.found) missing.add('wallet');

    final category = categoryRes.found
        ? categoryRes.category
        : (type == 'income'
            ? FinanceDefaults.incomeCategory
            : FinanceDefaults.expenseCategory);
    if (!categoryRes.found) missing.add('category');

    if (!amountRes.found) missing.add('amount');
    if (!dtRes.dateExplicit && !dtRes.timeExplicit) missing.add('datetime');
    if (title.isEmpty) missing.add('title');

    final confidence = _confidenceScore(
      amountFound: amountRes.found,
      typeExplicit: typeRes.explicit,
      walletFound: walletRes.found,
      walletAmbiguous: walletRes.ambiguous,
      categoryFound: categoryRes.found,
      categoryAmbiguous: categoryRes.ambiguous,
      dateOrTimeExplicit: dtRes.dateExplicit || dtRes.timeExplicit,
      titleFound: title.isNotEmpty,
    );

    final ambiguous = walletRes.ambiguous || categoryRes.ambiguous;

    return ParsedFinance(
      type: type,
      title: title.isEmpty ? (categoryRes.found ? categoryRes.category : 'transaksi') : title,
      amount: amountRes.amount,
      dateTime: dtRes.dateTime,
      wallet: wallet,
      category: category,
      confidence: confidence,
      missingFields: missing,
      ambiguous: ambiguous,
      rawText: rawText,
      normalizedText: normalized,
    );
  }

  double _confidenceScore({
    required bool amountFound,
    required bool typeExplicit,
    required bool walletFound,
    required bool walletAmbiguous,
    required bool categoryFound,
    required bool categoryAmbiguous,
    required bool dateOrTimeExplicit,
    required bool titleFound,
  }) {
    double score = 0;
    score += amountFound ? 0.40 : 0.0;
    score += typeExplicit ? 0.10 : 0.0;
    score += walletFound ? 0.15 : 0.0;
    score += categoryFound ? 0.15 : 0.0;
    score += dateOrTimeExplicit ? 0.10 : 0.0;
    score += titleFound ? 0.10 : 0.0;

    if (walletAmbiguous) score -= 0.10;
    if (categoryAmbiguous) score -= 0.05;

    if (score < 0) score = 0;
    if (score > 1) score = 1;
    return double.parse(score.toStringAsFixed(2));
  }
}
