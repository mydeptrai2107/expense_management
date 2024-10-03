class User{
  String userId;
  String email;
  String password;

  User({
    required this.userId,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      email: map['email'],
      password: map['password'],
    );
  }
}