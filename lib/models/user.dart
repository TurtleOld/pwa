class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'token': token,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        firstName.hashCode ^
        lastName.hashCode;
  }
}
