import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
    final formattedDate =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    return formattedDate;
  }