class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    this.email,
    this.firstname,
    this.lastname,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final role = map['roles'];
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      firstname: map['firstname'] as String?,
      lastname: map['lastname'] as String?,
      role: role is Map<String, dynamic>
          ? role['role'] as String? ?? 'customer'
          : 'customer',
    );
  }

  final String id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final String role;

  bool get isAdmin => role == 'admin';

  String get displayName {
    final name = [firstname, lastname]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
    if (name.isNotEmpty) return name;
    return email ?? 'RIFFS member';
  }

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.id == id &&
      other.email == email &&
      other.firstname == firstname &&
      other.lastname == lastname &&
      other.role == role;

  @override
  int get hashCode => Object.hash(id, email, firstname, lastname, role);
}
