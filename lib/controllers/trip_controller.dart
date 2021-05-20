import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/controllers/api_controller.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/connectivity_controller.dart';
import 'package:smart_fleet/controllers/db_controller.dart';
import 'package:smart_fleet/controllers/loading_controller.dart';
import 'package:smart_fleet/models/trip_model.dart';
import 'package:smart_fleet/pages/login_screen.dart';

class TripController extends GetxController {
  LoadingController loadingController = Get.put(LoadingController());
  ApiController apiController = Get.put(ApiController());
  DbController dbController = Get.find();
  ConnectivityController connectivityController =
      Get.put(ConnectivityController());
  AuthController authController = Get.find();
  var tripFormkey = GlobalKey<FormState>();
  var activityFormkey = GlobalKey<FormState>();
  List<TripModel> alltrips = [];
  List<TripActivitiesDto> allActivities = [];
  TripModel selectedTrip;
  TripActivitiesDto selectedActivity;
  // List<ActivityModel> activitesList = [];

/* --------------------------- variables for trips -------------------------- */

  String tripTitle, tripDescription, tripFrom, tripTo;
  double tripAmount;
  DateTime startDate = DateTime.now(), endData = DateTime.now();
  RefreshController activityRefreshController =
      RefreshController(initialRefresh: false);
  RefreshController tripRefreshController =
      RefreshController(initialRefresh: false);
  // ignore: missing_return
  //

/* ----------------------------variables for tripActivity ---------------------------- */
  String activityDescription;
  double activityAmount;
  String transactionType = 'Loan';
  DateTime activityDate = DateTime.now();

/* -------------------------- controller for trips -------------------------- */
  TextEditingController tripTitleController = TextEditingController();
  TextEditingController tripDescriptionController = TextEditingController();
  TextEditingController tripFromController = TextEditingController();
  TextEditingController tripToController = TextEditingController();
  TextEditingController tripAmountController = TextEditingController();

/* ---------------------- controller for activity page ---------------------- */
  TextEditingController activityDescriptionController = TextEditingController();
  TextEditingController activityAmountController = TextEditingController();

  // ignore: missing_return
  String validator(val) {
    if (val == '') {
      return 'Field Is Required';
    }
  }

  // ignore: missing_return
  String amountValidator(val) {
    if (val == '') {
      return 'Field Is Required';
    }
    if (double.tryParse(val) == null) {
      return 'Please Enter amount in double form';
    }
  }

/* -------------------------------------------------------------------------- */
/*                               all about trip                               */
/* -------------------------------------------------------------------------- */

  getTrips() async {
    if (connectivityController.isInternetAvailable.value) {
      apiController.getAllTrips(authController.userModel,
          selectedUser: authController.selectedUser);
    } else {
      tripRefreshController.refreshCompleted();

      await getOfflineTrips();
      update();
    }
  }

  getOfflineTrips() async {
    alltrips = await dbController.getAllTrips();
    update();
  }

  saveTrip() async {
    if (tripFormkey.currentState.validate()) {
      tripFormkey.currentState.save();
      TripModel _tripModel = TripModel();
      _tripModel.description = tripDescription;
      _tripModel.title = tripTitle;
      _tripModel.amount = tripAmount;
      _tripModel.from = tripFrom;
      _tripModel.to = tripTo;
      _tripModel.startDate = startDate;
      _tripModel.endDate = endData;
      if (connectivityController.isInternetAvailable.value) {
        apiController.addTrip(authController.userModel, _tripModel);
      } else {
        await dbController.saveOfflineTrip(_tripModel);
        Get.back();
        Get.snackbar('Success', 'Trip Added successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        getOfflineTrips();
      }
    }
  }

  gettripsForSync() async {
    List<TripModel> _listforUpdate = [];
    List<TripActivitiesDto> _listfroUpdateActivity = [];
    _listforUpdate = await dbController.getofflineUpdateTrips();
    _listfroUpdateActivity = await dbController.getofflineUpdateActivites();
    if (_listforUpdate.length < 1 && _listfroUpdateActivity.length < 1) {
      List<TripModel> _list = [];
      _list = await dbController.getOfflineTrips();
      print(_list.length);
      bool checkToken = isTokenValid(dbController.localExpireTime);
      if (checkToken) {
        for (var i = 0; i < _list.length; i++) {
          await syncTrip(_list[i]);
        }
        await getOfflineTrips();

        loadingController.stopLoading();
        tripRefreshController.refreshCompleted();
      } else {
        Get.off(() => LoginPage());
      }
      await getActivitesForSync();
    } else {
      bool checkToken = isTokenValid(dbController.localExpireTime);

      if (checkToken) {
        for (var i = 0; i < _listforUpdate.length; i++) {
          await apiController.updateOfflineTrip(
              dbController.localToken, _listforUpdate[i]);
        }
        for (var i = 0; i < _listfroUpdateActivity.length; i++) {
          await apiController.updateOfflineActivity(
              dbController.localToken, _listfroUpdateActivity[i]);
        }
      } else {
        Get.off(() => LoginPage());
      }
      gettripsForSync();
    }
  }

  syncTrip(TripModel tripData) async {
    bool _upload = false;
    _upload = await apiController.syncTrip(dbController.localToken, tripData);
  }

  updateTrip() async {
    if (tripFormkey.currentState.validate()) {
      tripFormkey.currentState.save();
      TripModel _tripModel = selectedTrip;
      _tripModel.description = tripDescription;
      _tripModel.title = tripTitle;
      _tripModel.amount = tripAmount;
      _tripModel.from = tripFrom;
      _tripModel.to = tripTo;
      _tripModel.startDate = startDate;
      _tripModel.endDate = endData;
      if (connectivityController.isInternetAvailable.value) {
        apiController.updateTrip(authController.userModel, _tripModel);
      } else {
        await dbController.updateTrip(_tripModel);
        Get.back();
        Get.snackbar('Success', 'Trip Updated successfully',
            backgroundColor: Colors.green.withOpacity(0.7));

        getOfflineTrips();
      }
    }
  }

  getDataForEditTrip() {
    tripTitleController.text = selectedTrip.title;
    tripDescriptionController.text = selectedTrip.description;
    tripFromController.text = selectedTrip.from;
    tripAmountController.text = selectedTrip.amount.toString();
    tripToController.text = selectedTrip.to;
    startDate = selectedTrip.startDate ?? DateTime.now();
    // endData = selectedTrip.endDate is String
    //     ? DateTime.parse(selectedTrip.endDate)
    //     : selectedTrip.endDate ?? DateTime.now();
  }
/* -------------------------------------------------------------------------- */
/*                             all about activites                            */
/* -------------------------------------------------------------------------- */

  refreshActivites() async {
    loadingController.showLoading();
    if (connectivityController.isInternetAvailable.value) {
      await getSaveActivitesForOfflineSave(alltrips);
    }
    await getOfflineActivites(selectedTrip);
    loadingController.stopLoading();
    activityRefreshController.refreshCompleted();
  }

  getOfflineActivites(TripModel tripData) async {
    // getActivitesForSync();
    tripData.tripActivitiesDto.clear();
    tripData.tripActivitiesDto = await dbController.getActivity(tripData.id);
    print(tripData.tripActivitiesDto);
    update();
  }

  getActivities() async {
    await getActivitesForSync();
    // apiController.getAllActivites(authController.userModel, selectedTrip);
    refreshActivites();
  }

  getSaveActivitesForOfflineSave(List<TripModel> list) async {
    List<TripActivitiesDto> _activitieslist = [];
    // loadingController.showLoading();
    for (var i = 0; i < list.length; i++) {
      var _sublist = await apiController.getAllActivitesForOfflineSave(
          authController.userModel, list[i]);
      {
        if (_sublist != null) {
          _activitieslist.addAll(_sublist);
        }
      }
    }
    await dbController.saveAllActivities(_activitieslist);
    // loadingController.stopLoading();
    // print(_activitieslist);
  }

  getActivitesForSync() async {
    List _list = [];
    List _list2 = [];
    List _list3 = [];
    _list = await dbController.getOfflineTrips();
    _list2 = await dbController.getofflineUpdateActivites();
    _list3 = await dbController.getofflineUpdateTrips();

    if (_list.length < 1 && _list2.length < 1 && _list3.length < 1) {
      loadingController.showLoading();
      List<TripActivitiesDto> _list = [];
      _list = await dbController.getOfflineActivites();
      print(_list.length);
      bool checkToken = isTokenValid(dbController.localExpireTime);
      if (checkToken) {
        for (var i = 0; i < _list.length; i++) {
          // await syncTrip(_list[i]);
          await syncActivity(_list[i]);
        }
      } else {
        Get.off(() => LoginPage());
      }
      loadingController.stopLoading();
      activityRefreshController.refreshCompleted();
    } else {
      gettripsForSync();
    }
  }

  isTokenValid(String tokenExpireDate) {
    dbController.checkUserLoginStatus();
    DateTime expireTime;
    expireTime = DateTime.parse(tokenExpireDate);
    if (expireTime.isAfter(DateTime.now())) {
      return true;
    } else {
      return false;
    }
  }

  syncActivity(TripActivitiesDto activityData) async {
    bool _upload = false;
    _upload =
        await apiController.syncActivity(dbController.localToken, activityData);
    if (_upload ?? false) {
      dbController.updateStatusOfActivity(activityData);
    }
  }

  saveActivity() async {
    if (activityFormkey.currentState.validate()) {
      activityFormkey.currentState.save();
      TripActivitiesDto _tripActivity = TripActivitiesDto();
      _tripActivity.price = activityAmount;
      _tripActivity.date = activityDate;
      _tripActivity.description = activityDescription;
      _tripActivity.transactionType = transactionType;
      _tripActivity.tripId = selectedTrip.id;

      if (connectivityController.isInternetAvailable.value &&
          selectedTrip.status == 'Online') {
        await apiController.addActivity(
            authController.userModel, _tripActivity);
        // await getSaveActivitesForOfflineSave(alltrips);
      } else {
        await dbController.saveOfflineActivity(_tripActivity);
      }
      Get.back();
      Get.snackbar('Success', 'Activity Added successfully',
          backgroundColor: Colors.green.withOpacity(0.7));
      await getOfflineActivites(selectedTrip);
    }
  }

  updateActivity() async {
    if (activityFormkey.currentState.validate()) {
      activityFormkey.currentState.save();
      TripActivitiesDto _tripActivity = selectedActivity;
      _tripActivity.price = activityAmount;
      _tripActivity.date = activityDate;
      _tripActivity.description = activityDescription;
      _tripActivity.transactionType = transactionType;
      _tripActivity.tripId = selectedTrip.id;
      if (connectivityController.isInternetAvailable.value &&
          selectedTrip.status == 'Online') {
        apiController.updateActivity(authController.userModel, _tripActivity);
      } else {
        await dbController.updateActivitY(_tripActivity);
        Get.back();
        Get.snackbar('Success', 'Activity Updated successfully',
            backgroundColor: Colors.green.withOpacity(0.7));
        // tripController.selectedTrip.tripActivitiesDto.add(activityData);
        getOfflineActivites(selectedTrip);
      }
    }
  }

  getDataForEditActivity() {
    activityAmountController.text = selectedActivity.price.toString();
    activityDescriptionController.text = selectedActivity.description;
    transactionType = selectedActivity.transactionType;
    activityDate = selectedActivity.date ?? DateTime.now();
  }

  deleteTrip() {
    apiController.deleteTrip(authController.userModel, selectedTrip);
  }

  deleteActivity() {
    apiController.deleteActivity(authController.userModel, selectedActivity);
  }

  clear() {
    endData = DateTime.now();
    startDate = DateTime.now();
    activityDate = DateTime.now();
    transactionType = 'Loan';
    tripTitleController.clear();
    tripDescriptionController.clear();
    tripFromController.clear();
    tripToController.clear();
    activityDescriptionController.clear();
    activityAmountController.clear();
    tripAmountController.clear();
  }
  // getTripsForUser() {
  //   apiController.getAllTripsForUser(authController.userModel);
  // }
}
