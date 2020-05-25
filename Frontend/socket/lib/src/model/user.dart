class User {
  int id;
  String name;
  String email;

  User({
    this.id,
    this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}
