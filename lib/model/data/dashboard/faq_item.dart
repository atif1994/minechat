import 'package:flutter/foundation.dart';

@immutable
class FaqItem {
  final String question;
  final int count;
  const FaqItem({required this.question, required this.count});
}
