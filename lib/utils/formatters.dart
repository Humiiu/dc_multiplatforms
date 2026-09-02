import 'package:intl/intl.dart';

class AppFormatters {
  static String rupiah(int n) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(n).replaceFirst('Rp', 'Rp ');
  }

  static String date(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }
}
