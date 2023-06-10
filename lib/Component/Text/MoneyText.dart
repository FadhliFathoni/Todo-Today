import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String MoneyText(value) {
  final rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return rupiahFormatter.format(value);
}
