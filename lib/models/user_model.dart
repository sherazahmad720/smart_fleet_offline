import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel(
      {this.email,
      this.password,
      this.firstName,
      this.lastName,
      this.phoneNumber,
      this.expiredIn,
      this.id,
      this.userType,
      this.token});

  String email;
  String id;
  String password;
  String firstName;
  String lastName;
  String phoneNumber;
  String token;
  String expiredIn;
  String userType;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      email: json["email"],
      password: json["password"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      token: json["bearerToken"],
      expiredIn: json['expiresIn'],
      userType: json['userType'],
      phoneNumber: json['phoneNumber'],
      id: json['id']);

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
      };
}
