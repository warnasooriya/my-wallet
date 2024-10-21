class BudgetItems {
  String id;
  String type;
  String section;
  String description;
  String date;
  double amount;
  String userId;
  String budgetId;

  BudgetItems(
      {required this.id,
      required this.type,
      required this.section,
      required this.description,
      required this.date,
      required this.amount,
      required this.userId,
      required this.budgetId});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'type': type ?? '',
      'section': section ?? '',
      'description': description ?? '',
      'date': date ?? '',
      'amount': amount ?? 0.0,
      'userId': userId ?? '',
      'budgetId': budgetId ?? ''
    };
  }

  // Convert Map to Item object
  factory BudgetItems.fromMap(Map<String, dynamic> map) {
    return BudgetItems(
      id: map['id'],
      type: map['type'],
      section: map['section'],
      description: map['description'],
      date: map['date'],
      amount: map['amount'],
      userId: map['userId'],
      budgetId: map['budgetId'],
    );
  }
}
