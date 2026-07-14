import 'package:aws_quiz_app/models/scoring.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// FSRS 指標を活かした分析ダッシュボード。
/// - 復習優先度の4象限（difficulty × retrievability）
/// - 復習負荷予測（今後14日の halving_date 到来数）
/// - mastery 分布ヒストグラム
class FsrsDashboard extends StatelessWidget {
  final Scoring scoring;
  const FsrsDashboard(this.scoring);

  static const TextStyle _headerStyle = TextStyle(
      fontSize: 12.0, fontWeight: FontWeight.w600, color: Colors.white70);

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    children.add(_buildQuadrants(scoring.quadrants));
    children.add(SizedBox(height: 8.0));
    children.add(_buildDueForecast(context, scoring.dueForecast));
    children.add(SizedBox(height: 8.0));
    children.add(_buildMasteryHistogram(context));
    if (children.isEmpty) return SizedBox(height: 0.0);

    return Container(
        decoration: BoxDecoration(color: Colors.blueGrey[900]),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children));
  }

  // ---------------------------------------------------------------
  // 1. 復習優先度 4象限
  // ---------------------------------------------------------------
  Widget _buildQuadrants(Quadrants q) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text("復習優先度（難易度 × 想起度）", style: _headerStyle)),
      Row(children: [
        _quadrantCard("最優先", "難×忘れかけ", q.danger, Colors.red[400]),
        SizedBox(width: 6.0),
        _quadrantCard("軽く復習", "易×忘れかけ", q.effort, Colors.orange[400]),
      ]),
      SizedBox(height: 6.0),
      Row(children: [
        _quadrantCard("油断注意", "難×維持中", q.fragile, Colors.amber[600]),
        SizedBox(width: 6.0),
        _quadrantCard("安定", "易×維持中", q.stable, Colors.green[400]),
      ]),
      Padding(
          padding: EdgeInsets.only(left: 4.0, top: 4.0),
          child: Text("未学習: ${q.unlearned}問",
              style: TextStyle(fontSize: 10.0, color: Colors.white54))),
    ]);
  }

  Widget _quadrantCard(String title, String subtitle, int count, Color color) {
    return Expanded(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                // 非一様Border(left)とborderRadiusは併用不可のため一様枠線にする
                border: Border.all(color: color, width: 1.5),
                borderRadius: BorderRadius.circular(4.0)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 9.0, color: Colors.white54)),
                      ]),
                  Text("$count",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ])));
  }

  // ---------------------------------------------------------------
  // 2. 復習負荷予測（今後14日）
  // ---------------------------------------------------------------
  Widget _buildDueForecast(BuildContext context, DueForecast forecast) {
    final data = forecast.days
        .map((d) => _BarData(d.date.substring(5), d.count.toDouble()))
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text("復習負荷予測（14日間）", style: _headerStyle)),
        SizedBox(width: 8.0),
        if (forecast.overdue > 0)
          Container(
              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
              decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(8.0)),
              child: Text(
                  "期限切れ ${forecast.overdue}問・延べ超過 ${forecast.overdueDays}日",
                  style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
      ]),
      if (forecast.overdue > 0 && forecast.lostRetention > 0)
        Padding(
            padding: EdgeInsets.only(left: 4.0, top: 2.0),
            child: Text(
                "超過による定着ロス 約${forecast.lostRetention.toStringAsFixed(1)}pt"
                "（最適日に復習していれば維持できた分）",
                style: TextStyle(fontSize: 10.0, color: Colors.red[200]))),
      SizedBox(
          height: 140,
          child: SfCartesianChart(
              margin: EdgeInsets.all(4.0),
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                  labelStyle:
                      TextStyle(fontSize: 8.0, color: Colors.white70),
                  majorGridLines: MajorGridLines(width: 0),
                  // 14日分のラベルが混み合うため2日おきに表示
                  interval: 2),
              primaryYAxis: NumericAxis(
                  labelStyle:
                      TextStyle(fontSize: 8.0, color: Colors.white70),
                  majorGridLines:
                      MajorGridLines(width: 0.5, color: Colors.white12)),
              series: <CartesianSeries>[
                ColumnSeries<_BarData, String>(
                    dataSource: data,
                    xValueMapper: (_BarData d, _) => d.x,
                    yValueMapper: (_BarData d, _) => d.y,
                    pointColorMapper: (_BarData d, int index) =>
                        index == 0 ? Colors.lightBlue[300] : Colors.teal[400],
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                            fontSize: 8.0, color: Colors.white70)))
              ])),
    ]);
  }

  // ---------------------------------------------------------------
  // 3. mastery 分布ヒストグラム
  // ---------------------------------------------------------------
  Widget _buildMasteryHistogram(BuildContext context) {
    final data = scoring.masteryCounts
        .map((m) => _BarData(m.label, m.count.toDouble()))
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
              "習熟度(mastery)分布  平均: ${scoring.avg_mastery.toStringAsFixed(1)}",
              style: _headerStyle)),
      SizedBox(
          height: 140,
          child: SfCartesianChart(
              margin: EdgeInsets.all(4.0),
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                  labelStyle:
                      TextStyle(fontSize: 9.0, color: Colors.white70),
                  majorGridLines: MajorGridLines(width: 0)),
              primaryYAxis: NumericAxis(
                  labelStyle:
                      TextStyle(fontSize: 8.0, color: Colors.white70),
                  majorGridLines:
                      MajorGridLines(width: 0.5, color: Colors.white12)),
              series: <CartesianSeries>[
                ColumnSeries<_BarData, String>(
                    dataSource: data,
                    xValueMapper: (_BarData d, _) => d.x,
                    yValueMapper: (_BarData d, _) => d.y,
                    pointColorMapper: (_BarData d, int index) =>
                        _masteryColor(index),
                    dataLabelSettings: DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                            fontSize: 8.0, color: Colors.white70)))
              ])),
    ]);
  }

  Color _masteryColor(int index) {
    // 0(未定着)→赤系、100~(熟達)→緑系のグラデーション
    const colors = [
      Color(0xFFE57373), // 0
      Color(0xFFFF8A65), // ~20
      Color(0xFFFFB74D), // ~40
      Color(0xFFFFD54F), // ~60
      Color(0xFFAED581), // ~80
      Color(0xFF81C784), // ~100
      Color(0xFF4DB6AC), // 100~
    ];
    return colors[index < colors.length ? index : colors.length - 1];
  }
}

class _BarData {
  final String x;
  final double y;
  _BarData(this.x, this.y);
}
