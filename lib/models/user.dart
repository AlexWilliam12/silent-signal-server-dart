class User {
  int? id;
  String? name;
  String? picture;

  User.dto({
    required this.name,
    required this.picture,
  });

  User.model({
    required this.id,
    required this.name,
    required this.picture,
  });

  User.id({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'picture': picture,
    };
  }
}
