class AppUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'deputy' или 'staff'
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': DateTime.now().millisecondsSinceEpoch,
      'isActive': isActive,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? 'Пользователь',
      role: map['role'] ?? 'staff',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLogin: map['lastLogin'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLogin'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  // Проверка прав доступа
  bool get isDeputy => role == 'deputy';
  bool get isStaff => role == 'staff';

  // Может ли пользователь редактировать расписание
  bool get canEditSchedule => isDeputy;

  // Может ли пользователь управлять документами
  bool get canManageDocuments => isDeputy || isStaff;

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, name: $name, role: $role}';
  }
}
