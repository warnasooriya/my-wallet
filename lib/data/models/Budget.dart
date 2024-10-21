class Budget {
  String id;
  String name;
  String userId;
  String startDate;
  String endDate;
  String? imageUrl;

  Budget(
      {required this.id,
      required this.name,
      required this.userId,
      required this.startDate,
      required this.endDate,
      this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'userId': userId ?? '',
      'startDate': startDate ?? '',
      'endDate': endDate ?? '',
      'imageUrl': imageUrl ?? 0,
    };
  }

  // Convert Map to Item object
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      name: map['name'],
      userId: map['userId'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      imageUrl: map['imageUrl'],
    );
  }
}
