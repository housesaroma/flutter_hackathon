class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final String? department;
  final bool isDeputy;
  final bool isAdmin;
  final String? deputyId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    this.department,
    required this.isDeputy,
    this.isAdmin = false,
    this.deputyId,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      department: map['department'],
      isDeputy: map['isDeputy'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
      deputyId: map['deputyId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'department': department,
      'isDeputy': isDeputy,
      'isAdmin': isAdmin,
      'deputyId': deputyId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}
