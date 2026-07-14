import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static String today() {
    initializeDateFormatting('ja');
    var formater = new DateFormat('yyyy-MM-dd', "ja_JP");
    final DateTime _now = DateTime.now();
    return formater.format(_now);
  }
}
