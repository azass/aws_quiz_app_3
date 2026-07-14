import 'package:flutter/material.dart';

class MenuIcon {
  IconData icon;
  Color color = Colors.indigo;
  MenuIcon(IconData icon) : icon = icon;

  void setupColor(bool exist) {
    color = (exist) ? Colors.pinkAccent:Colors.indigo;
  }

  void setColor(Color color) {
    this.color = color;
  }
}
