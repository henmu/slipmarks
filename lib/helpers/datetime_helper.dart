import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTime(String? timestamp) {
    if (timestamp == null) return 'Unknown';

    final dateTime = DateTime.tryParse(timestamp);
    if (dateTime == null) return 'Invalid Date';

    // Convert the server's timestamp from GMT to the local timezone
    final localDateTime = dateTime.toLocal();

    final formatter = DateFormat('dd/MM HH:mm');
    return formatter.format(localDateTime);
  }
}
