class User {
  String? userId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? regDate;
  double? userCredit;
  //String? userAddress; // NEW
  //String? userLatitude; // Existing new
  //String? userLongitude; // Existing new

  User({
    this.userId,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.regDate,
    //this.userAddress,
    //this.userLatitude,
    //this.userLongitude,
    this.userCredit,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString() ?? '';
    name = json['user_name']?.toString() ?? 'No Name';
    email = json['user_email']?.toString() ?? '';
    password = json['user_password']?.toString() ?? '';
    phone = json['user_phone']?.toString() ?? '';
    regDate = json['user_regdate']?.toString() ?? '';
    //userAddress = json['user_address'];
    //userLatitude = json['user_latitude'];
    //userLongitude = json['user_longitude'];
    userCredit = double.tryParse(json['user_credit']?.toString() ?? '0.0');
  }

  get userName => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_name'] = name;
    data['user_email'] = email;
    data['user_password'] = password;
    data['user_phone'] = phone;
    data['user_regdate'] = regDate;
    //data['user_address'] = userAddress;
    //data['user_latitude'] = userLatitude;
    //data['user_longitude'] = userLongitude;
    data['user_credit'] = userCredit;
    return data;
  }
}
