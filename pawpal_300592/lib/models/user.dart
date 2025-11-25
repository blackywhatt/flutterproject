class User {
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? regDate;

  User({
    this.userId,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.regDate,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    name = json['user_name'];
    email = json['user_email'];
    password = json['user_password'];
    phone = json['user_phone'];
    regDate = json['user_regdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_name'] = name;
    data['user_email'] = email;
    data['user_password'] = password;
    data['user_phone'] = phone;
    data['user_regdate'] = regDate;
    return data;
  }
}
