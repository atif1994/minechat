import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductModel {
  final String id;
  final TextEditingController nameCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController priceCtrl;
  final RxString nameError;
  final RxString descriptionError;
  final RxString priceError;
  final RxString selectedImage;

  ProductModel({
    required this.id,
    required this.nameCtrl,
    required this.descriptionCtrl,
    required this.priceCtrl,
    required this.nameError,
    required this.descriptionError,
    required this.priceError,
    required this.selectedImage,
  });

  String get name => nameCtrl.text;
  String get description => descriptionCtrl.text;
  String get price => priceCtrl.text;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': selectedImage.value,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      nameCtrl: TextEditingController(text: map['name'] ?? ''),
      descriptionCtrl: TextEditingController(text: map['description'] ?? ''),
      priceCtrl: TextEditingController(text: map['price'] ?? ''),
      nameError: ''.obs,
      descriptionError: ''.obs,
      priceError: ''.obs,
      selectedImage: (map['image'] ?? '').obs,
    );
  }

  ProductModel copyWith({
    String? id,
    TextEditingController? nameCtrl,
    TextEditingController? descriptionCtrl,
    TextEditingController? priceCtrl,
    RxString? nameError,
    RxString? descriptionError,
    RxString? priceError,
    RxString? selectedImage,
  }) {
    return ProductModel(
      id: id ?? this.id,
      nameCtrl: nameCtrl ?? this.nameCtrl,
      descriptionCtrl: descriptionCtrl ?? this.descriptionCtrl,
      priceCtrl: priceCtrl ?? this.priceCtrl,
      nameError: nameError ?? this.nameError,
      descriptionError: descriptionError ?? this.descriptionError,
      priceError: priceError ?? this.priceError,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}
