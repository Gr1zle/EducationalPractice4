import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';

void main() {
  // Убирает решётку из адреса: /calculator вместо /#/calculator
  usePathUrlStrategy();
  runApp(const CalcApp());
}