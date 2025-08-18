import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FAQModel {
  final String id;
  final TextEditingController questionCtrl;
  final TextEditingController answerCtrl;
  final RxString questionError;
  final RxString answerError;

  FAQModel({
    required this.id,
    required this.questionCtrl,
    required this.answerCtrl,
    required this.questionError,
    required this.answerError,
  });

  String get question => questionCtrl.text;
  String get answer => answerCtrl.text;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  factory FAQModel.fromMap(Map<String, dynamic> map) {
    return FAQModel(
      id: map['id'] ?? '',
      questionCtrl: TextEditingController(text: map['question'] ?? ''),
      answerCtrl: TextEditingController(text: map['answer'] ?? ''),
      questionError: ''.obs,
      answerError: ''.obs,
    );
  }

  FAQModel copyWith({
    String? id,
    TextEditingController? questionCtrl,
    TextEditingController? answerCtrl,
    RxString? questionError,
    RxString? answerError,
  }) {
    return FAQModel(
      id: id ?? this.id,
      questionCtrl: questionCtrl ?? this.questionCtrl,
      answerCtrl: answerCtrl ?? this.answerCtrl,
      questionError: questionError ?? this.questionError,
      answerError: answerError ?? this.answerError,
    );
  }
}
