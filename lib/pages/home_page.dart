import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/constants/constants.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/connectivity_controller.dart';
import 'package:smart_fleet/controllers/db_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/pages/login_screen.dart';
import 'package:smart_fleet/widgets/customAlerDialog.dart';
import 'package:smart_fleet/widgets/logout_dialog.dart';
import 'package:smart_fleet/widgets/trips_card.dart';

import 'activity_page.dart';
import 'add_trip_page.dart';

class HomePage extends StatelessWidget {
  final DbController dbController = Get.find();
  final AuthController authController = Get.find();
  final TripController tripController = Get.put(TripController());
  final ConnectivityController connectivityController = Get.find();
  @override
  Widget build(BuildContext context) {
    // customContext = context;
    var f = NumberFormat("\u{020A6},###.##", "en_US");

    tripController.getTrips();

    return Scaffold(
        appBar: AppBar(
          title: Text('Smart Fleet'),
          backgroundColor: Color(0xff753a88),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => CircleAvatar(
                  radius: 5,
                  backgroundColor:
                      connectivityController.isInternetAvailable.value
                          ? Colors.green
                          : Colors.red[900],
                  // child: Text(connectivityController.isInternetAvailable.value
                  //     .toString()),
                ),
              ),
            ),
            if (authController.userModel.userType == 'User')
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    tripController.clear();
                    Get.to(AddTripPage(
                      type: 'AddNew',
                    ));
                  }),
            if (authController.userModel.userType == 'User')
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    logoutDialog(context, logoutAction: () async {
                      authController.clear();
                      await dbController.logout();
                      Get.back();
                      Get.off(LoginPage(), preventDuplicates: false);
                    });
                  }),
          ],
        ),
        body: GetBuilder<TripController>(
          builder: (_) {
            return Container(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SmartRefresher(
                      enablePullUp: false,
                      header: WaterDropHeader(
                        waterDropColor: Colors.deepPurpleAccent,
                      ),
                      controller: _.tripRefreshController,
                      onRefresh: () {
                        _.getTrips();
                      },
                      child: ListView.builder(
                          itemCount: _.alltrips.length,
                          itemBuilder: (ctx, index) {
                            var tripData = _.alltrips[index];
                            return InkWell(
                              onTap: () {
                                print('id is -->${tripData.id}');
                                print(
                                    'activity Local id is -->${tripData.localId}');

                                _.selectedTrip = tripData;
                                // _.getActivities();
                                _.getOfflineActivites(tripData);
                                Get.to(ActivityPage());
                              },
                              onLongPress: () {
                                _.selectedTrip = tripData;
                                // Get.dialog(customAlertDialog());
                                customAlertDialog(context,
                                    userType: authController.userModel.userType,
                                    editAction: () {
                                  _.getDataForEditTrip();
                                  Get.off(AddTripPage(
                                    type: 'Update',
                                  ));
                                }, deleteAction: () {
                                  _.deleteTrip();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: tripsCard(
                                    updateStatus: tripData.updateStatus,
                                    status: tripData.status,
                                    isAdmin:
                                        authController.userModel.userType !=
                                            'User',
                                    amount: f.format(tripData.amount),
                                    description: tripData.description,
                                    email: '',
                                    endDate: tripData.endDate != null &&
                                            tripData.endDate != ''
                                        ? tripData.endDate is String
                                            ? DateFormat('dd MMM ,yyyy').format(
                                                DateTime.parse(
                                                    tripData.endDate))
                                            : DateFormat('dd MMM ,yyyy')
                                                .format(tripData.endDate)
                                        : 'No Date Added',
                                    from: tripData.from,
                                    phoneNo: '',
                                    startDate: tripData.startDate != null
                                        ? DateFormat('dd MMM ,yyyy')
                                            .format(tripData.startDate)
                                        : 'No Date Added',
                                    title: tripData.title,
                                    to: tripData.to,
                                    userName: ''),
                              ),
                            );
                          }),
                    )));
          },
        ));
  }
}
