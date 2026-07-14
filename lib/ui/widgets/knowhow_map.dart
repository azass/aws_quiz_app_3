import 'package:aws_quiz_app/models/scoring.dart';
import 'package:flutter/material.dart';

/// ノウハウマップ: タグ配下の用語（Term）階層を習熟度ヒートマップで表示する。
/// - インデント = 用語の階層（level）
/// - 背景色     = mastery（赤=未定着 → 緑=熟達）
/// - 右端       = 正答率と問題数
/// 弱い知識ノードが構造の中のどこにあるかを一目で示す。
class KnowhowMap extends StatelessWidget {
  final List<ScoringTableItem> items;
  const KnowhowMap(this.items);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return SizedBox(height: 0.0);
    return Container(
        decoration: BoxDecoration(color: Colors.blueGrey[900]),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: Text("ノウハウマップ（知識 × 習熟度）",
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70))),
              _buildLegend(),
              SizedBox(height: 4.0),
              ...items.map((item) => _buildNode(item)),
            ]));
  }

  Widget _buildLegend() {
    Widget chip(String label, Color color) => Padding(
        padding: EdgeInsets.only(right: 6.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, color: color),
          SizedBox(width: 3.0),
          Text(label,
              style: TextStyle(fontSize: 9.0, color: Colors.white54)),
        ]));
    return Padding(
        padding: EdgeInsets.only(left: 4.0),
        child: Row(children: [
          chip("未定着", _heatColor(10)),
          chip("学習中", _heatColor(50)),
          chip("定着", _heatColor(90)),
          chip("熟達", _heatColor(120)),
        ]));
  }

  Widget _buildNode(ScoringTableItem item) {
    final color = _heatColor(item.avgMastery);
    return Container(
        margin: EdgeInsets.only(left: item.indent * 3.0, bottom: 3.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.42),
            // 非一様Border(left)とborderRadiusは併用不可のため一様枠線にする
            border: Border.all(color: color, width: 1.2),
            borderRadius: BorderRadius.circular(3.0)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))),
              Text(
                  "M ${item.avgMastery.toStringAsFixed(0)}  "
                  "正答 ${(item.correctAnswerRate * 100).round()}%  "
                  "${item.questionCount}問",
                  style: TextStyle(fontSize: 9.5, color: Colors.white70)),
            ]));
  }

  /// mastery(0〜120+) を赤→黄→緑のヒートカラーに変換する。
  Color _heatColor(double mastery) {
    if (mastery < 20) return Color(0xFFE57373); // 未定着
    if (mastery < 40) return Color(0xFFFF8A65);
    if (mastery < 60) return Color(0xFFFFB74D);
    if (mastery < 80) return Color(0xFFFFD54F); // 学習中
    if (mastery < 100) return Color(0xFFAED581);
    if (mastery < 120) return Color(0xFF81C784); // 定着
    return Color(0xFF4DB6AC); // 熟達
  }
}
