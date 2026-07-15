import 'package:flutter/material.dart';

final historyColor = [
  Colors.white,
  Colors.red.shade200,
  Colors.pink.shade100,
  Colors.red.shade100,
  Colors.pink.shade50,
  Colors.red.shade50,
  Colors.orange.shade100,
  Colors.yellow.shade300,
  Colors.limeAccent.shade200,
  Colors.lightGreenAccent.shade200,
  Colors.lightBlueAccent.shade100,
];

final scoringName = [
  "",
  "知識不足",
  "理解不足",
  "うろ覚え",
  "読取不足",
  "注意不足",
  "山勘",
  "残像",
  "半自力未満",
  "半自力以上",
  "自力",
];

String formatTime(int time) {
  int sec = time % 60;
  int min = time ~/ 60;
  int min2 = min % 60;
  int hour = min ~/ 60;
  if (hour > 0) {
    return "$hour時間$min2分$sec秒";
  } else if (min > 0) {
    return "$min分$sec秒";
  } else {
    return "$sec秒";
  }
}

void showLoading(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: Duration(milliseconds: 250), // ダイアログフェードインmsec
    barrierColor: Colors.black.withValues(alpha: 0.5), // 画面マスクの透明度
    pageBuilder:
        (
          BuildContext context,
          Animation animation,
          Animation secondaryAnimation,
        ) {
          return Center(child: CircularProgressIndicator());
        },
  );
}

var icons = [
  Icon(Icons.emoji_events_rounded),
  Icon(Icons.emoji_objects_outlined),
  Icon(Icons.fact_check_outlined),
  Icon(Icons.file_present),
  Icon(Icons.folder_open),
  Icon(Icons.golf_course),
  Icon(Icons.grading),
  Icon(Icons.military_tech),
  Icon(Icons.note_alt_outlined),
  Icon(Icons.power_settings_new),
  Icon(Icons.published_with_changes),
  Icon(Icons.recommend_outlined),
  Icon(Icons.self_improvement),
  Icon(Icons.skateboarding),
  Icon(Icons.task_alt),
  Icon(Icons.thumb_up_outlined),
  Icon(Icons.my_library_add_outlined),
];

final BACK_COLOR = Colors.pinkAccent;
// final CARD_COLOR = Colors.blueGrey[400];
// final CARD_TEXT_COLOR = Colors.teal[800];
final CARD_COLOR = Colors.teal.shade50;
final CARD_TEXT_COLOR = Colors.green.shade800;

final List termColors = [
  {"color": Colors.indigoAccent.shade200, "text": "1"},
  {"color": Colors.blue.shade600, "text": "2"},
  {"color": Colors.indigo.shade300, "text": "3"},
  {"color": Colors.blue.shade300, "text": "4"},
  {"color": Colors.teal.shade300, "text": "5"},
  {"color": Colors.green.shade300, "text": "6"},
];

final priority = ["捨て問", "後回し", "通常", "必須"];
