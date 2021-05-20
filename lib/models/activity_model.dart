// To parse this JSON data, do
//
//     final activityModel = activityModelFromJson(jsonString);

import 'dart:convert';

ActivityModel activityModelFromJson(String str) =>
    ActivityModel.fromJson(json.decode(str));

String activityModelToJson(ActivityModel data) => json.encode(data.toJson());

class ActivityModel {
  ActivityModel({
    this.id,
    this.date,
    this.transactionType,
    this.price,
    this.tripId,
    this.appUserId,
    this.description,
  });

  int id;
  DateTime date;
  String transactionType;
  int price;
  int tripId;
  String appUserId;
  String description;

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id: json["id"],
        date: DateTime.parse(json["date"]),
        transactionType: json["transactionType"],
        price: json["price"],
        tripId: json["tripId"],
        appUserId: json["appUserId"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date.toIso8601String(),
        "transactionType": transactionType,
        "price": price,
        "tripId": tripId,
        "appUserId": appUserId,
        "description": description,
      };
}
