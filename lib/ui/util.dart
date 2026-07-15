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

enum AppPalette { deepFocus, organicMint, activeGamified }

class AppPaletteColors {
  final String name;
  final String description;
  final Color primary;
  final Color accent;
  final Color background;
  final Color card;
  final Color text;

  const AppPaletteColors({
    required this.name,
    required this.description,
    required this.primary,
    required this.accent,
    required this.background,
    required this.card,
    required this.text,
  });
}

const appPalettes = <AppPalette, AppPaletteColors>{
  AppPalette.deepFocus: AppPaletteColors(
    name: 'Deep Focus',
    description: '知的集中・王道ブルー',
    primary: Color(0xFF1E3A5F),
    accent: Color(0xFF3B82F6),
    background: Color(0xFF315B8A),
    card: Color(0xFFF4F8FF),
    text: Color(0xFF16324F),
  ),
  AppPalette.organicMint: AppPaletteColors(
    name: 'Organic Mint',
    description: '疲労軽減・読解力重視',
    primary: Color(0xFF2F6F64),
    accent: Color(0xFF55B89A),
    background: Color(0xFF3F8F7F),
    card: Color(0xFFF1FBF7),
    text: Color(0xFF24564E),
  ),
  AppPalette.activeGamified: AppPaletteColors(
    name: 'Active Gamified',
    description: '継続・モチベーション重視',
    primary: Color(0xFF6D28D9),
    accent: Color(0xFFF97316),
    background: Color(0xFFF97316),
    card: Color(0xFFFFF7ED),
    text: Color(0xFF5B21B6),
  ),
};

AppPaletteColors currentPaletteColors = appPalettes[AppPalette.deepFocus]!;
Color BACK_COLOR = currentPaletteColors.background;
Color CARD_COLOR = currentPaletteColors.card;
Color CARD_TEXT_COLOR = currentPaletteColors.text;

class AppPaletteState extends ChangeNotifier {
  AppPalette _selected = AppPalette.deepFocus;

  AppPalette get selected => _selected;
  AppPaletteColors get colors => appPalettes[_selected]!;

  void select(AppPalette palette) {
    if (_selected == palette) return;
    _selected = palette;
    currentPaletteColors = colors;
    BACK_COLOR = colors.background;
    CARD_COLOR = colors.card;
    CARD_TEXT_COLOR = colors.text;
    notifyListeners();
  }
}

final List termColors = [
  {"color": Colors.indigoAccent.shade200, "text": "1"},
  {"color": Colors.blue.shade600, "text": "2"},
  {"color": Colors.indigo.shade300, "text": "3"},
  {"color": Colors.blue.shade300, "text": "4"},
  {"color": Colors.teal.shade300, "text": "5"},
  {"color": Colors.green.shade300, "text": "6"},
];

final priority = ["捨て問", "後回し", "通常", "必須"];
