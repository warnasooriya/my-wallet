class Expensestype {
  String id;
  String? name;
  String? userId;

  Expensestype({required this.id, required this.name, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userId': userId ?? '',
    };
  }

  // Convert Map to Item object
  factory Expensestype.fromMap(Map<String, dynamic> map) {
    return Expensestype(
      id: map['id'],
      name: map['name'],
      userId: map['userId'],
    );
  }
}
