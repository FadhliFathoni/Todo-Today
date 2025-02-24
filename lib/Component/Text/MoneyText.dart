import 'package:intl/intl.dart';

String MoneyText(dynamic value) {
  if (value is num) {
    final rupiahFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return rupiahFormatter.format(value);
  } else {
    return 'Invalid value';
  }
}
