import 'package:aws_quiz_app/resources/api_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DailyRecord {
  final String answerDate;
  final int executeCount;
  final int correctCount;
  final int executedTime;
  final int point;

  const DailyRecord(this.answerDate, this.executeCount, this.correctCount,
      this.point, this.executedTime);

  DailyRecord.fromMap(Map<String, dynamic> data)
      : answerDate = data['answer_date'],
        executeCount = data['execute_count'],
        correctCount = data['correct_count'],
        executedTime =
            (data['executed_time'] == null) ? 0 : data['executed_time'],
        point = data['point'];

  static Map<String, DailyRecord> fromData(List<Map<String, dynamic>> data) {
    Map<String, DailyRecord> map = {};
    if (data.length == 0) return map;
    data
        .map((record) => DailyRecord.fromMap(record))
        .toList()
        .forEach((record) => map[record.answerDate] = record);
    return map;
  }

  static Future<List<DailyRecord>> readyDailyRecords() async {
    List<DailyRecord> records = [];
    initializeDateFormatting('ja');
    var formater = new DateFormat('yyyy-MM-dd', "ja_JP");
    final DateTime _now = DateTime.now();
    DateTime _date = _now.add(new Duration(days: 7 - _now.weekday));
    var toDate = formater.format(_date);
    var fromDate = formater.format(_date.subtract(Duration(days: 41)));
    Map<String, DailyRecord> map = await getDailyRecords(fromDate, toDate);
    for (int i = 0; i < 6; i++) {
      List<DailyRecord> _records = [];
      for (int j = 0; j < 7; j++) {
        if (map.containsKey(formater.format(_date))) {
          _records.add(map[formater.format(_date)]);
        } else {
          _records.add(DailyRecord(formater.format(_date), 0, 0, 0, 0));
        }
        _date = _date.subtract(Duration(days: 1));
      }
      for (int k = 6; k >= 0; k--) {
        records.add(_records[k]);
      }
    }
    return records;
  }
}
