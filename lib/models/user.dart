class User {
  late String name;
  late String? picture;

  User({
    required this.name,
    required this.picture,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'picture': picture,
    };
  }
}
