import 'package:flutter/material.dart';

class Transactions {
  String id;
  String type;
  String section;
  String userId;
  String date;
  double amount;
  String? description;
  Image? image;

  Transactions(
      {required this.id,
      required this.type,
      required this.section,
      required this.userId,
      required this.date,
      required this.amount,
      this.description,
      this.image});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'section': section,
      'userId': userId,
      'date': date,
      'amount': amount,
      'description': description ?? '',
      'image': image ?? null,
    };
  }

  // Convert Map to Item object
  factory Transactions.fromMap(Map<String, dynamic> map) {
    return Transactions(
      id: map['id'],
      type: map['type'],
      section: map['section'],
      userId: map['userId'],
      date: map['date'],
      amount: map['amount'],
      description: map['description'],
      image: map['image'],
    );
  }
}
