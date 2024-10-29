import 'package:intl/intl.dart';

String formatDateTime(DateTime dateTime) {
  final formattedDate =
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
  return formattedDate;
}

String formatDateWithTime(DateTime dateTime) {
  final formattedDateTime =
      DateFormat('EEEE, dd MMMM yyyy HH:mm:ss', 'id_ID').format(dateTime);
  return formattedDateTime;
}
