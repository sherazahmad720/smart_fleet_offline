import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/models/trip_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'dart:async';
import 'package:path/path.dart';

class DbController extends GetxController {
  // final TripController tripController = Get.put(TripController());
  final box = GetStorage();
  String localEmail;
  String localExpireTime;
  String localToken;
  String userType;
  TextEditingController localEmailController = TextEditingController();
  login(expireTime, email, token, type) async {
    localExpireTime = expireTime;
    localEmail = email;
    localToken = token;
    userType = token;
    await box.write('ExpireTime', expireTime);
    await box.write('Email', email);
    await box.write('Token', token);
    await box.write('UserType', type);
  }

  checkUserLoginStatus() {
    AuthController authController = Get.put(AuthController());
    localExpireTime = box.read('ExpireTime');
    localEmail = box.read('Email');
    localToken = box.read('Token');
    userType = box.read('UserType');
    authController.userModel.token = localToken;
    if (localExpireTime == null) {
      localExpireTime = '';
    }
    if (localEmail == null) {
      localEmail = '';
    }
    if (localToken == null) {
      localToken = '';
    }
    if (userType == null) {
      userType = '';
    }
    localEmailController.text = localEmail;
  }

  logout() async {
    await box.write('ExpireTime', '');
    await box.write('Email', '');
    await box.write('Token', '');
    await box.write('UserType', '');
    await deleteAllData();
    checkUserLoginStatus();
  }

/* -------------------------------------------------------------------------- */
/*                              sql lite section                              */
/* -------------------------------------------------------------------------- */
  static Database _db;
  Database db2;
  static const String DB_NAME = 'smart_fleet.db';

/* --------------------------------- tables --------------------------------- */
  static const String TABLETRIP = 'TableTrip';
  static const String TABLEACTIVTY = 'TableActivity';

/* ----------------------------- trip variables ----------------------------- */
  static const String ID = 'id';
  static const String TRIPID = 'tripId';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';
  static const String FROM = 'from_place';
  static const String TO = 'to_place';
  static const String AMOUNT = 'amount';
  static const String STARTDATE = 'startAt';
  static const String ENDDATE = 'endAt';
  static const String STATUS = 'status';
  static const String UPDATESTATUS = 'updateStatus';

/* --------------------------- activity variables --------------------------- */

  static const String ACTIVITYID = 'activityId';
  static const String DATE = 'date';
  static const String TYPE = 'type';
  static const String PRICE = 'price';
  static const String LOAN = 'loan';
  static const String EXPANSE = 'expanse';
  static const String INCOME = 'income';
  Future<Database> get db async {
    if (_db != null) {
      return db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

/* -------------------------------------------------------------------------- */
/*                          data base initialization                          */
/* -------------------------------------------------------------------------- */

  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLETRIP($ID INTEGER PRIMARY KEY AUTOINCREMENT,$TRIPID INTEGER,$Title TEXT,$DESCRIPTION  Text,$FROM  Text,$TO  Text,$AMOUNT  Text,$STARTDATE  Text,$ENDDATE  Text,$STATUS  Text,$UPDATESTATUS  Text)");
    await db.execute(
        "CREATE TABLE $TABLEACTIVTY($ID INTEGER PRIMARY KEY AUTOINCREMENT,$ACTIVITYID INTEGER,$TRIPID TEXT,$DATE TEXT,$TYPE  Text,$PRICE  Text,$DESCRIPTION ,  Text,$STATUS  Text,$UPDATESTATUS  Text)");
  }
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */

/* -------------------- delete all online trips for sync -------------------- */

  Future deleteOnlineTrips() async {
    if (db2 == null) {
      db2 = await db;
    }
    var changes = await db2
        .rawDelete('DELETE FROM $TABLETRIP WHERE $STATUS =?', ['Online']);
    return db2;
  }

/* ------------------ delete all  online activies for sync ------------------ */

  Future deleteOnlineActivities() async {
    if (db2 == null) {
      db2 = await db;
    }
    var changes = await db2
        .rawDelete('DELETE FROM $TABLEACTIVTY WHERE $STATUS =?', ['Online']);
    return db2;
  }

/* ------------------------ delete specific activity ------------------------ */

  Future deleteActivity(TripActivitiesDto activityData) async {
    if (db2 == null) {
      db2 = await db;
    }
    var changes = await db2.rawDelete(
        'DELETE FROM $TABLEACTIVTY WHERE $ID =?', ['${activityData.localId}']);
    return db2;
  }

/* -------------------------- delete specific trip -------------------------- */

  Future deleteTrip(TripModel tripData) async {
    if (db2 == null) {
      db2 = await db;
    }
    var changes = await db2.rawDelete(
        'DELETE FROM $TABLETRIP WHERE $ID =?', ['${tripData.localId}']);
    return db2;
  }

/* --------------------------- get unsynced trips --------------------------- */

  getOfflineTrips() async {
    if (db2 == null) {
      db2 = await db;
    }
    List<TripModel> list = [];
    List<Map> maps = await db2
        .rawQuery('SELECT * FROM $TABLETRIP WHERE $STATUS =?', ['Offline']);

    for (int i = 0; i < maps.length; i++) {
      TripModel _trip = TripModel.fromMap(maps[i]);
      list.add(_trip);
    }

    return list;
  }

/* ----------------------- get trips for update sync----------------------- */

  getofflineUpdateTrips() async {
    if (db2 == null) {
      db2 = await db;
    }
    List<TripModel> list = [];
    List<Map> maps = await db2
        .rawQuery('SELECT * FROM $TABLETRIP WHERE $UPDATESTATUS =?', ['yes']);

    for (int i = 0; i < maps.length; i++) {
      TripModel _trip = TripModel.fromMap(maps[i]);
      list.add(_trip);
    }

    return list;
  }

/* ---------------------- get activites for sync update --------------------- */

  getofflineUpdateActivites() async {
    if (db2 == null) {
      db2 = await db;
    }
    List<TripActivitiesDto> list = [];
    List<Map> maps = await db2.rawQuery(
        'SELECT * FROM $TABLEACTIVTY WHERE $UPDATESTATUS =?', ['yes']);

    for (int i = 0; i < maps.length; i++) {
      TripActivitiesDto _trip = TripActivitiesDto.fromMap(maps[i]);
      list.add(_trip);
    }

    return list;
  }

/* ------------------------ get all offline activites ----------------------- */

  getOfflineActivites() async {
    if (db2 == null) {
      db2 = await db;
    }
    List<TripActivitiesDto> list = [];
    List<Map> maps = await db2
        .rawQuery('SELECT * FROM $TABLEACTIVTY WHERE $STATUS =?', ['Offline']);

    for (int i = 0; i < maps.length; i++) {
      TripActivitiesDto _trip = TripActivitiesDto.fromMap(maps[i]);
      list.add(_trip);
    }

    return list;
  }

/* -------------------- update statuss of trip after sync ------------------- */

  updateStatusOfTrip(TripModel tripData, oldTripId) async {
    if (db2 == null) {
      db2 = await db;
    }
    if (tripData.id != oldTripId) {
      List<TripActivitiesDto> offlineActivites = await getOfflineActivites();
      for (var i = 0; i < offlineActivites.length; i++) {
        if (offlineActivites[i].tripId == oldTripId) {
          await db2.rawUpdate('UPDATE $TABLEACTIVTY SET $TRIPID=? WHERE $ID=?',
              [tripData.id, offlineActivites[i].localId]);
        }
      }
      // await db2.rawUpdate(
      //     'UPDATE $TABLEACTIVTY SET $TRIPID=? WHERE $TRIPID=?',
      //     [tripData.id, oldTripId]);
    }
    await db2.rawUpdate('UPDATE $TABLETRIP SET $STATUS=?,$TRIPID=? WHERE $ID=?',
        ['Online', tripData.id, tripData.localId]);

    return true;
  }

/* ---------------------- change status of update sync of Trip---------------------- */

  updateTripSyncStatus(TripModel tripData) async {
    if (db2 == null) {
      db2 = await db;
    }

    await db2.rawUpdate('UPDATE $TABLETRIP SET $UPDATESTATUS=? WHERE $ID=?',
        ['', tripData.localId]);
  }

/* ------------- change the status of update activity after sync ------------ */

  updateActivitySyncStatus(TripActivitiesDto activityData) async {
    if (db2 == null) {
      db2 = await db;
    }

    await db2.rawUpdate('UPDATE $TABLETRIP SET $UPDATESTATUS=? WHERE $ID=?',
        ['', activityData.localId]);
  }

/* ------------------------- save all trips offline ------------------------- */

  saveOfflineTrip(TripModel tripData, {bool fromOnline = false}) async {
    if (db2 == null) {
      db2 = await db;
    }
    var _map = tripData.toMap(status: fromOnline ? 'Online' : 'Offline');
    await db2.insert(TABLETRIP, _map);
    if (tripData.id == null) {
      int _id = await getLastSaveId();
      await db2
          .rawUpdate('UPDATE $TABLETRIP SET $TRIPID=? WHERE $ID=?', [_id, _id]);
    }
  }

/* ------------------------------ update a trip ----------------------------- */

  updateTrip(TripModel tripData) async {
    if (db2 == null) {
      db2 = await db;
    }
    var _map = tripData.toMapUpdate(
        isUpdate: tripData.status == 'Online' ? 'yes' : '');
    // db2.update(TABLETRIP, _map, where: ID, whereArgs: [tripData.localId]);
    await db2.rawUpdate(
        'UPDATE $TABLETRIP SET $TITLE=?,$DESCRIPTION=?,$FROM=?,$TO=?,$AMOUNT=?,$STARTDATE=?,$UPDATESTATUS=? WHERE $ID=?',
        [
          tripData.title,
          tripData.description,
          tripData.from,
          tripData.to,
          tripData.amount,
          tripData.startDate != null
              ? DateFormat('dd MMM ,yyyy').format(tripData.startDate)
              : '',
          tripData.status == 'Online' ? 'yes' : '',
          tripData.localId
        ]);
  }

/* ---------------------------- update a activity --------------------------- */

  updateActivitY(TripActivitiesDto activitiesDto, {fromOnline = false}) async {
    if (db2 == null) {
      db2 = await db;
    }
    // var _map = tripData.toMapUpdate(
    //     isUpdate: tripData.status == 'Online' ? 'yes' : '');
    // db2.update(TABLETRIP, _map, where: ID, whereArgs: [tripData.localId]);
    await db2.rawUpdate(
        'UPDATE $TABLEACTIVTY SET $DATE=?,$TYPE=?,$PRICE=?,$DESCRIPTION=?,$UPDATESTATUS=? WHERE $ID=?',
        [
          activitiesDto.date != null
              ? DateFormat('dd MMM ,yyyy').format(activitiesDto.date)
              : '',
          activitiesDto.transactionType,
          activitiesDto.price.toString(),
          activitiesDto.description,
          fromOnline
              ? ''
              : activitiesDto.status == 'Online'
                  ? 'yes'
                  : '',
          activitiesDto.localId
        ]);
  }

/* ------------------------- get last id in database ------------------------ */

  getLastSaveId() async {
    int _id;
    if (db2 == null) {
      db2 = await db;
    }
    List<TripModel> allData = await getAllTrips();
    _id = allData.last.localId;
    return _id;
  }

/* ----------------------- save all trips in database ----------------------- */

  saveAllTrips(List<TripModel> list) async {
    await deleteOnlineTrips();
    if (db2 == null) {
      db2 = await db;
    }

    var i = 0;
    while (i < list.length) {
      var _map = list[i].toMap();
      await db2.insert(TABLETRIP, _map);
      i++;
    }
  }

/* --------------------- save all activites in database --------------------- */

  saveAllActivities(List<TripActivitiesDto> list) async {
    await deleteOnlineActivities();
    if (db2 == null) {
      db2 = await db;
    }
    var i = 0;
    while (i < list.length) {
      var _map = list[i].toMap();
      await db2.insert(TABLEACTIVTY, _map);
      i++;
    }
    getAllActivites();
  }

/* ------------------------------ get all trips ----------------------------- */

  Future getAllTrips() async {
    // TripController tripController = Get.put(TripController());
    if (db2 == null) {
      db2 = await db;
    }
    List<TripModel> list = [];

    List<Map> maps = await db2.rawQuery('Select * from $TABLETRIP');
    for (int i = 0; i < maps.length; i++) {
      TripModel _trip = TripModel.fromMap(maps[i]);
      list.add(_trip);
    }
    // tripController.alltrips = list;
    // tripController.update();
    return list;
  }

/* ---------------------------- get all activites --------------------------- */

  Future getAllActivites() async {
    if (db2 == null) {
      db2 = await db;
    }
    List<TripActivitiesDto> list = [];

    List<Map> maps = await db2.rawQuery('Select * from $TABLEACTIVTY');
    for (int i = 0; i < maps.length; i++) {
      TripActivitiesDto _trip = TripActivitiesDto.fromMap(maps[i]);
      list.add(_trip);
    }
    print(list);
  }

/* ------------------------- get a specific activity ------------------------ */

  getActivity(tripId) async {
    if (db2 == null) {
      db2 = await db;
    }
    List<TripActivitiesDto> list = [];

    List<Map> maps = await db2
        .rawQuery('SELECT * FROM $TABLEACTIVTY WHERE $TRIPID =?', ['$tripId']);
    for (int i = 0; i < maps.length; i++) {
      TripActivitiesDto _trip = TripActivitiesDto.fromMap(maps[i]);
      list.add(_trip);
    }
    return list;
  }

/* -------------------------- save offline activity ------------------------- */

  saveOfflineActivity(TripActivitiesDto activityData,
      {fromonline = false}) async {
    if (db2 == null) {
      db2 = await db;
    }
    var _map = activityData.toMap(statuss: fromonline ? 'Online' : 'Offline');
    await db2.insert(TABLEACTIVTY, _map);
  }

  updateStatusOfActivity(TripActivitiesDto activityData) async {
    if (db2 == null) {
      db2 = await db;
    }
    await db2.rawUpdate(
        'UPDATE $TABLEACTIVTY SET $STATUS=?,$ACTIVITYID=? WHERE $ID=?',
        ['Online', activityData.id, activityData.localId]);
    return true;
  }

  deleteAllData() async {
    if (db2 == null) {
      db2 = await db;
    }
    await db2.delete(TABLEACTIVTY);
    await db2.delete(TABLETRIP);
  }
}
