import 'package:flutter/material.dart';

class MultipleSelector extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MultipleSelectorState();

}

class _MultipleSelectorState extends State<MultipleSelector> {

  List<int> _executeTimes = [-1];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        runSpacing: 10.0,
        spacing: 6.4,
        children: <Widget>[
          SizedBox(width: 0.0),
          _buildChip("指定なし", -1),
          _buildChip("０回", 0),
          _buildChip("１回", 1),
          _buildChip("２回", 2),
          _buildChip("３回", 3),
          _buildChip("４回以上", 4,),
          SizedBox(width: 5.0),
        ],
      ),
    );
  }

  ActionChip _buildChip(String label, int value) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.white),
      backgroundColor: _bgColor(_isOn(value)),
      onPressed: () => _selectExecuteTime(value),
    );
  }

  Color _bgColor(bool isSelected) {
    return isSelected ? Colors.indigo : Colors.grey.shade600;
  }

  _isOn(int i) {
    return _executeTimes.contains(i);
  }

  _selectExecuteTime(int i) {
    setState(() {
      _executeTimes = _selectTime(_executeTimes, i);
    });
  }

  List<int> _selectTime(List<int> times, int i) {
    if (i == -1) {
      times = [-1];
    } else {
      if (times.contains(-1)) {
        times = [i];
      } else if (times.contains(i)) {
        times.remove(i);
      } else {
        times.add(i);
      }
      if (times.length == 0) {
        times = [i];
      }
    }
    return times;
  }
}