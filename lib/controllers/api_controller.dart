import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/connectivity_controller.dart';
import 'package:smart_fleet/controllers/db_controller.dart';
import 'package:smart_fleet/controllers/loading_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/models/trip_model.dart';
import 'package:smart_fleet/models/user_model.dart';
import 'package:smart_fleet/pages/all_users.dart';
import 'package:smart_fleet/pages/home_page.dart';

class ApiController extends GetxController {
  DbController dbController = Get.find();
  ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  LoadingController loadingController = Get.put(LoadingController());
  userLogin() async {
    loadingController.showLoading();

    dynamic response = await http
        .get('dis/dashboard/getDashboardList', headers: <String, String>{});
    loadingController.stopLoading();
    if (response.statusCode == 200) {}
    loadingController.stopLoading();
  }

/* ---------------------------- sign up for user ---------------------------- */

  signUp(UserModel userData) async {
    AuthController authController = Get.put(AuthController());
    loadingController.showLoading();

    try {
      dynamic response = await http
          .post('https://smartfleets.azurewebsites.net/api/account/register',
              headers: <String, String>{
                // 'Authorization': '',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(userData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        var data = jsonDecode(response.body);
        loadingController.stopLoading();
        if (data['responseCode'] == 400) {
          authController.errorList = data['error'];
          authController.update();
        } else if (data['responseCode'] == 200) {
          authController.errorList = [];
          authController.update();
          Get.back();
          Get.snackbar('Success', data['responseMessage'],
              backgroundColor: Colors.green.withOpacity(0.4));
          Get.back();
          login(userData);
        }
      } else if (response.statusCode == 400) {
        var data = jsonDecode(response.body);

        Get.snackbar('Success', data['responseMessage'] ?? '',
            backgroundColor: Colors.red.withOpacity(0.4));
        authController.errorList.add(data['responseMessage']);
        authController.update();
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

/* ----------------------------- login for user ----------------------------- */

  login(UserModel userData) async {
    final _tempEmail = userData.email;
    AuthController authController = Get.put(AuthController());
    loadingController.showLoading();
    try {
      dynamic response = await http
          .post('https://smartfleets.azurewebsites.net/api/account/login',
              headers: <String, String>{
                // 'Authorization': '',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(
                  {'email': userData.email, 'password': userData.password}))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print(jsonDecode(response.body));
        // var data = jsonDecode(response.body);
        loadingController.stopLoading();
        if (data['responseCode'] == 200) {
          userData = UserModel.fromJson(data['data']);
          userData.token = data['data']['bearerToken'];
          userData.expiredIn = data['data']['expiresIn'];
          authController.errorList = [];
          authController.userModel = userData;
          authController.update();
          print(userData.token);
          print(userData.userType);

          await dbController.login(userData.expiredIn, _tempEmail,
              userData.token, userData.userType);
          userData.userType == 'User'
              ? Get.off(() => HomePage())
              : Get.off(() => AllUserPage(), preventDuplicates: false);
          if (userData.userType == 'Admin') {
            getAllUser(userData);
          }
          // Get.back();

          Get.snackbar('Success', data['responseMessage'],
              backgroundColor: Colors.green.withOpacity(0.4));
        } else if (data['responseCode'] == 400) {
          authController.errorList = [data['responseMessage']];
          authController.update();

          Get.snackbar('Success', data['responseMessage'],
              backgroundColor: Colors.green.withOpacity(0.4));
        }
      } else if (response.statusCode == 404) {
        Get.snackbar('Error found', data['responseMessage'] ?? '',
            backgroundColor: Colors.red.withOpacity(0.4));
        authController.errorList = [data['error']];
        authController.update();
      } else if (response.statusCode == 400) {
        authController.errorList = [data['responseMessage'] ?? data['title']];
        // authController.errorList = [data['responseMessage']];
        authController.update();
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  getAllUser(UserModel userData) async {
    AuthController authController = Get.find();
    authController.allUserList = [];
    update();
    authController.update();
    var url = 'https://smartfleets.azurewebsites.net/api/users';
    try {
      dynamic response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          // 'Authorization':
          //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      // authController.tripRefreshController.refreshCompleted();

      var jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonData['responseCode'] == 200) {
          List listOfUser = jsonData['data'];
          // authController.allUserList.clear();
          listOfUser.forEach((element) {
            var _userData = UserModel.fromJson(element);
            authController.allUserList.add(_userData);
            // getAllActivites(userData, _tripModelData);
          });

          authController.update();
          loadingController.stopLoading();
          authController.userRefreshController.refreshCompleted();
        }
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();
      authController.userRefreshController.refreshCompleted();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.stopLoading();
      authController.userRefreshController.refreshCompleted();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

/* ------------------------------ get all trips ----------------------------- */

  getAllTrips(UserModel userData, {UserModel selectedUser}) async {
    bool isInternet = await connectivityController.checkData();
    TripController tripController = Get.put(TripController());
    if (isInternet) {
      loadingController.showLoading();
      List<TripModel> _listforUpdate = [];
      _listforUpdate = await dbController.getofflineUpdateTrips();

/* -------------------------- update updated trips -------------------------- */

      if (_listforUpdate.length > 0) {
        for (var i = 0; i < _listforUpdate.length; i++) {
          await updateOfflineTrip(userData.token, _listforUpdate[i]);
        }
      }
      List<TripActivitiesDto> _listfroUpdateActivity = [];

      _listfroUpdateActivity = await dbController.getofflineUpdateActivites();

/* ------------------------ update updated activites ------------------------ */

      if (_listfroUpdateActivity.length > 0) {
        for (var i = 0; i < _listfroUpdateActivity.length; i++) {
          await updateOfflineActivity(
              dbController.localToken, _listfroUpdateActivity[i]);
        }
      }
      tripController.alltrips.clear();
      tripController.update();
      var url = userData.userType == 'User'
          ? 'https://smartfleets.azurewebsites.net/api/trip/user-trips'
          : 'https://smartfleets.azurewebsites.net/api/user-trips/${selectedUser.id}';
      try {
        dynamic response = await http.get(
          url,
          headers: <String, String>{
            'Authorization': 'bearer ' + "${userData.token}",
            // 'Authorization':
            //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
            'Content-Type': 'application/json',
          },
        ).timeout(Duration(seconds: 10));
        // loadingController.stopLoading();
        // tripController.tripRefreshController.refreshCompleted();
        update();
        var jsonData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (jsonData['responseCode'] == 200) {
            List<TripModel> _alltrips = [];
            List listOfTrips = jsonData['data'];
            // tripController.alltrips.clear();
            listOfTrips.forEach((element) {
              var _tripModelData = TripModel.fromJson(element);
              _alltrips.add(_tripModelData);
              // getAllActivites(userData, _tripModelData);
            });
            await dbController.saveAllTrips(_alltrips);
            await tripController.gettripsForSync();

            await tripController.getSaveActivitesForOfflineSave(_alltrips);
            // tripController.getOfflineTrips();
            loadingController.stopLoading();
            tripController.tripRefreshController.refreshCompleted();
          }
        }
      } on TimeoutException catch (_) {
        loadingController.stopLoading();
        tripController.tripRefreshController.refreshCompleted();

        Get.snackbar("Internet Issue",
            'please check you connection \n Your internet connection is not stable',
            backgroundColor: Colors.red.withOpacity(0.4));
      } on SocketException catch (_) {
        loadingController.stopLoading();
        tripController.tripRefreshController.refreshCompleted();

        Get.snackbar("Unknow issue found", 'There is some issue on server side',
            backgroundColor: Colors.red.withOpacity(0.4));
      }
    } else {
      Get.snackbar('No Internet found', 'Please check you internet');
      tripController.tripRefreshController.refreshCompleted();
    }
  }

/* ------------------ get activity against a specific trip ------------------ */

  getAllActivites(UserModel userData, TripModel tripData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    tripData.tripActivitiesDto.clear();
    tripData.activitiesCosts.clear();
    tripController.update();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    try {
      dynamic response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      tripController.activityRefreshController.refreshCompleted();

      var jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonData['responseCode'] == 200) {
          // tripData.amount = double.parse(jsonData['data']['amount'].toString());
          tripData.tripActivitiesDto = List<TripActivitiesDto>.from(
              jsonData['data']["tripActivitiesDto"]
                  .map((x) => TripActivitiesDto.fromJson(x)));
          tripData.activitiesCosts = List<ActivitiesCost>.from(jsonData['data']
                  ["activitiesCosts"]
              .map((x) => ActivitiesCost.fromJson(x)));
          tripController.update();
        }
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();
      tripController.activityRefreshController.refreshCompleted();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.stopLoading();
      tripController.activityRefreshController.refreshCompleted();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  getAllActivitesForOfflineSave(UserModel userData, TripModel tripData) async {
    TripController tripController = Get.find();
    List<TripActivitiesDto> _activityList = [];
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    try {
      dynamic response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      // loadingController.stopLoading();
      // tripController.activityRefreshController.refreshCompleted();

      var jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonData['responseCode'] == 200) {
          _activityList = List<TripActivitiesDto>.from(jsonData['data']
                  ["tripActivitiesDto"]
              .map((x) => TripActivitiesDto.fromJson(x)));
          return _activityList;
        }
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();
      tripController.activityRefreshController.refreshCompleted();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.stopLoading();
      tripController.activityRefreshController.refreshCompleted();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  addTrip(UserModel userData, TripModel tripData) async {
    final TripController tripController = Get.find();
    //
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip';
    try {
      dynamic response = await http
          .post(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "${userData.token}",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(tripData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Success', 'Trip Added successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        tripData.status = 'Online';
        tripData.id = jsonData['data']['id'];
        // tripController.alltrips.add(tripData);
        await dbController.saveOfflineTrip(tripData, fromOnline: true);
        tripController.getOfflineTrips();
        return true;
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  updateTrip(UserModel userData, TripModel tripData) async {
    AuthController authController = Get.find();

    // final TripController tripController = Get.find();
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    try {
      dynamic response = await http
          .put(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "${userData.token}",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(tripData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Success', 'Trip Updated successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        getAllTrips(userData, selectedUser: authController.selectedUser);

        // tripController.update();
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      } else if (response.statusCode == 404) {
        Get.back();
        Get.snackbar('Error', 'Trip Is Deleted',
            backgroundColor: Colors.red.withOpacity(0.7));
        getAllTrips(userData, selectedUser: authController.selectedUser);
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  updateOfflineTrip(token, TripModel tripData) async {
    AuthController authController = Get.find();

    // final TripController tripController = Get.find();
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    try {
      dynamic response = await http
          .put(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "$token",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(tripData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        dbController.updateTripSyncStatus(tripData);
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      } else if (response.statusCode == 404) {
        dbController.deleteTrip(tripData);
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  deleteTrip(UserModel userData, TripModel tripData) async {
    AuthController authController = Get.find();
    TripController tripController = Get.find();

    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip/${tripData.id}';
    try {
      dynamic response = await http.delete(
        url,
        headers: <String, String>{
          'Authorization': 'bearer ' + "${userData.token}",
          // 'Authorization':
          //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Success', 'Trip Deleted successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        // getAllTrips(userData, selectedUser: authController.selectedUser);
        dbController.deleteTrip(tripData);
        tripController.alltrips
            .removeWhere((element) => element.id == tripData.id);
        tripController.update();

        // tripController.update();
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  addActivity(UserModel userData, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip-activity';
    try {
      dynamic response = await http
          .post(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "${userData.token}",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(activityData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Get.back();
        // Get.snackbar('Success', 'Activity Added successfully',
        //     backgroundColor: Colors.green.withOpacity(0.7));
        // tripController.selectedTrip.tripActivitiesDto.add(activityData);
        TripActivitiesDto activityData =
            TripActivitiesDto.fromJson(jsonData['data']);
        activityData.status = 'Online';
        await dbController.saveOfflineActivity(activityData, fromonline: true);
        tripController.selectedTrip.tripActivitiesDto.add(activityData);
        // getAllActivites(userData, tripController.selectedTrip);
        // tripController.update();
        // getAllTrips(userData);

        tripController.update();
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  updateOfflineActivity(token, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url =
        'https://smartfleets.azurewebsites.net/api/trip-activity/${activityData.id}';
    try {
      dynamic response = await http
          .put(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "$token",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(activityData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        dbController.updateActivitySyncStatus(activityData);
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      } else if (response.statusCode == 404) {
        dbController.deleteActivity(activityData);
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  updateActivity(UserModel userData, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url =
        'https://smartfleets.azurewebsites.net/api/trip-activity/${activityData.id}';
    try {
      dynamic response = await http
          .put(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "${userData.token}",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(activityData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Success', 'Activity Updated successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        // tripController.selectedTrip.tripActivitiesDto.add(activityData);
        // await getAllActivites(userData, tripController.selectedTrip);
        // tripController.selectedActivity = activityData;
        await dbController.updateActivitY(activityData, fromOnline: true);
        tripController.getOfflineActivites(tripController.selectedTrip);

        // tripController.update();
        // getAllTrips(userData);

        // tripController.update();
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  deleteActivity(UserModel userData, TripActivitiesDto activityData) async {
    TripController tripController = Get.find();
    loadingController.showLoading();
    var url =
        'https://smartfleets.azurewebsites.net/api/trip-activity/${activityData.id}';
    try {
      dynamic response = await http.delete(url, headers: <String, String>{
        'Authorization': 'bearer ' + "${userData.token}",
        // 'Authorization':
        //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
        'Content-Type': 'application/json'
      }).timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // loadingController.showLoading();

        Get.back();
        Get.snackbar('Success', 'Activity Deleted successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        tripController.selectedTrip.tripActivitiesDto
            .removeWhere((element) => element.id == activityData.id);
        dbController.deleteActivity(activityData);
        // getAllTrips(userData);
        // getAllActivites(userData, tripController.selectedTrip);
        // loadingController.stopLoading();
        tripController.update();
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', jsonData['title'],
            backgroundColor: Colors.red.withOpacity(0.7));
      }
    } on TimeoutException catch (_) {
      Get.back();
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      Get.back();
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  syncTrip(token, TripModel tripData) async {
    // final TripController tripController = Get.find();
    //
    // loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip';
    try {
      dynamic response = await http
          .post(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "$token",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(tripData.toJson()))
          .timeout(Duration(seconds: 10));
      loadingController.stopLoading();
      var jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var oldId = tripData.id;
        tripData.id = jsonData['data']['id'];
        // Get.back();
        // Get.snackbar('Success', 'Trip Added successfully',
        //     backgroundColor: Colors.green.withOpacity(0.7));
        await dbController.updateStatusOfTrip(tripData, oldId);
        return true;
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }

  syncActivity(token, TripActivitiesDto activityData) async {
    // loadingController.showLoading();
    var url = 'https://smartfleets.azurewebsites.net/api/trip-activity';
    try {
      dynamic response = await http
          .post(url,
              headers: <String, String>{
                'Authorization': 'bearer ' + "$token",
                // 'Authorization':
                //     'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoiYWRtaW5AZ21haWwuY29tIiwianRpIjoiZWExYzQyZTktMWQ4OS00NDAxLWFhODItNDMyZWEzNGIyNTUwIiwiVXNlcklkIjoiNGMwN2E2NzctYTYzYi00ZGRkLTk1M2YtMzQ0YzcyZTI5YzFjIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE2MTgzMTUxOTYsImlzcyI6InRyaXBfZGlhcnkvYXBpIiwiYXVkIjoidHJpcF9kaWFyeS9jbGllbnQifQ.1y3IzEpaaEmUerpv09FdjoDhyDMmjzAzGzy6v4-RoJs',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(activityData.toJson()))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      }
    } on TimeoutException catch (_) {
      loadingController.stopLoading();

      Get.snackbar("Internet Issue",
          'please check you connection \n Your internet connection is not stable',
          backgroundColor: Colors.red.withOpacity(0.4));
    } on SocketException catch (_) {
      loadingController.showLoading();

      Get.snackbar("Unknow issue found", 'There is some issue on server side',
          backgroundColor: Colors.red.withOpacity(0.4));
    }
  }
}
