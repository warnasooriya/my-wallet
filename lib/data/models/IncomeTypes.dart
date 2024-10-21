class IncomeTypes {
  String id;
  String name;
  String userId;

  IncomeTypes({required this.id, required this.name, required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userId': userId ?? '',
    };
  }

  // Convert Map to Item object
  factory IncomeTypes.fromMap(Map<String, dynamic> map) {
    return IncomeTypes(
      id: map['id'],
      name: map['name'],
      userId: map['userId'],
    );
  }
}
