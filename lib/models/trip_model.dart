// To parse this JSON data, do
//
//     final tripModel = tripModelFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';

TripModel tripModelFromJson(String str) => TripModel.fromJson(json.decode(str));

String tripModelToJson(TripModel data) => json.encode(data.toJson());

class TripModel {
  TripModel(
      {this.id,
      this.localId,
      this.title,
      this.description,
      this.from,
      this.to,
      this.amount,
      this.startDate,
      this.endDate,
      this.status,
      this.updateStatus,
      this.tripActivitiesDto,
      this.appUserDto,
      this.activitiesCosts});

  int id;
  int localId;
  String title;
  String description;
  String from;
  String to;
  double amount;
  DateTime startDate;
  String status;
  String updateStatus;
  dynamic endDate;
  List<TripActivitiesDto> tripActivitiesDto;
  AppUserDto appUserDto;
  List<ActivitiesCost> activitiesCosts;
  TripModel.fromMap(Map<String, dynamic> map) {
    localId = map['id'];
    id = map["tripId"];
    title = map["Title"];
    description = map["description"];
    from = map["from_place"];
    to = map["to_place"];
    amount = double.parse(map["amount"]);
    startDate = DateFormat('dd MMM ,yyyy').parse(map["startAt"]);
    endDate = map["endAt"] != ''
        ? DateFormat('dd MMM ,yyyy').parse(map["endAt"])
        : '';
    status = map["status"];
    updateStatus = map["updateStatus"];
    activitiesCosts =
        List<ActivitiesCost>.from([].map((x) => ActivitiesCost.fromJson(x)));
    tripActivitiesDto = List<TripActivitiesDto>.from(
        [].map((x) => TripActivitiesDto.fromJson(x)));
  }
  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        from: json["from"],
        to: json["to"],
        amount: double.parse(json["amount"].toString()),
        startDate: DateTime.parse(json["startDate"]),
        endDate: json["endDate"],
        tripActivitiesDto: List<TripActivitiesDto>.from(
            json["tripActivitiesDto"]
                .map((x) => TripActivitiesDto.fromJson(x))),
        appUserDto: AppUserDto.fromJson(json["appUserDto"]),
        activitiesCosts: List<ActivitiesCost>.from(
            json["activitiesCosts"].map((x) => ActivitiesCost.fromJson(x))),
      );
  Map<String, dynamic> toMap({
    status = 'Online',
  }) =>
      {
        "id": null,
        "tripId": id,
        "title": title,
        "description": description,
        "from_place": from,
        "to_place": to,
        "amount": amount,
        "startAt": startDate != null
            ? DateFormat('dd MMM ,yyyy').format(startDate)
            : '',
        "endAt": endDate != null
            ? endDate is String
                ? DateFormat('dd MMM ,yyyy').format(DateTime.parse(endDate))
                : DateFormat('dd MMM ,yyyy').format(endDate)
            : '',
        "status": '$status',
        "updateStatus": ''
      };
  Map<String, dynamic> toMapUpdate({isUpdate = ''}) => {
        "tripId": id,
        "title": title,
        "description": description,
        "from_place": from,
        "to_place": to,
        "amount": amount,
        "startAt": startDate != null
            ? DateFormat('dd MMM ,yyyy').format(startDate)
            : '',
        "endAt": endDate != null
            ? endDate is String
                ? DateFormat('dd MMM ,yyyy').format(DateTime.parse(endDate))
                : DateFormat('dd MMM ,yyyy').format(endDate)
            : '',
        "status": '$status',
        "updateStatus": isUpdate
      };
  Map<String, dynamic> toJson() => {
        // "id": id,
        "title": title,
        "description": description,
        "from": from,
        "to": to,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate != ''
            ? endDate.toIso8601String()
            : DateTime.now().toIso8601String(),
        "amount": amount
        // "tripActivitiesDto":
        //     List<dynamic>.from(tripActivitiesDto.map((x) => x.toJson())),
        // "appUserDto": appUserDto.toJson(),
      };
}

class AppUserDto {
  AppUserDto({
    this.id,
    this.firstName,
    this.lastName,
    this.address,
    this.phoneNumber,
    this.email,
  });

  String id;
  String firstName;
  String lastName;
  dynamic address;
  String phoneNumber;
  String email;

  factory AppUserDto.fromJson(Map<String, dynamic> json) => AppUserDto(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        address: json["address"],
        phoneNumber: json["phoneNumber"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
        "phoneNumber": phoneNumber,
        "email": email,
      };
}

class TripActivitiesDto {
  TripActivitiesDto(
      {this.id,
      this.date,
      this.transactionType,
      this.price,
      this.tripId,
      this.appUserId,
      this.description,
      this.localId,
      this.status,
      this.updateStatus});

  int id;
  int localId;
  DateTime date;
  String transactionType;
  double price;
  int tripId;
  dynamic appUserId;
  String status;
  String updateStatus;
  String description;
  TripActivitiesDto.fromMap(Map<String, dynamic> map) {
    id = map['activityId'];
    localId = map['id'];
    date = DateFormat('dd MMM ,yyyy').parse(map["date"]);
    transactionType = map['type'];
    price = double.parse(map['price']);
    tripId = int.parse(map['tripId']);
    appUserId = '';
    description = map['description'];
    status = map['status'];
    updateStatus = map['updateStatus'];
  }
  factory TripActivitiesDto.fromJson(Map<String, dynamic> json) =>
      TripActivitiesDto(
        id: json["id"],
        date: DateTime.parse(json["date"]),
        transactionType: json["transactionType"],
        price: double.parse(json["price"].toString()),
        tripId: json["tripId"],
        appUserId: json["appUserId"],
        description: json["description"],
      );
  Map<String, dynamic> toMap({statuss = 'Online'}) => {
        'id': null,
        'activityId': id ?? -tripId,
        'tripId': tripId.toString(),
        'date': date != null ? DateFormat('dd MMM ,yyyy').format(date) : '',
        'type': transactionType,
        'price': price.toString(),
        'description': description,
        'status': statuss,
        'updateStatus': ''
      };
  Map<String, dynamic> toJson() => {
        // "id": id,
        "date": date.toIso8601String(),
        "transactionType": transactionType,
        "price": price,
        "tripId": tripId,
        // "appUserId": appUserId,
        "description": description,
      };
}

class ActivitiesCost {
  ActivitiesCost({
    this.transactionType,
    this.cost,
  });

  String transactionType;
  double cost;

  factory ActivitiesCost.fromJson(Map<String, dynamic> json) => ActivitiesCost(
        transactionType: json["transactionType"],
        cost: json["cost"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "transactionType": transactionType,
        "cost": cost,
      };
}
