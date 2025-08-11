import 'package:flutter/foundation.dart';

@immutable
class SeriesPoint {
  final String label; // "12am", "3am"...
  final double value;
  const SeriesPoint({required this.label, required this.value});
}
