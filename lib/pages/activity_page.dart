import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:smart_fleet/controllers/auth_controller.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/models/trip_model.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';
import 'package:smart_fleet/widgets/customAlerDialog.dart';
import 'package:smart_fleet/widgets/trips_activity_card.dart';
import 'package:intl/intl.dart';

import 'add_trip_activity_page.dart';

class ActivityPage extends StatelessWidget {
  final AuthController authController = Get.find();
  final f = NumberFormat("\u{020A6},###.##", "en_US");
  final totalF = NumberFormat("\u{020A6},###.#", "en_US");

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TripController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xff753a88),
            title: Text('Activities'),
            actions: [
              if (authController.userModel.userType == 'User')
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      controller.clear();
                      Get.to(AddTripActivityPage(
                        type: 'AddNew',
                      ));
                    })
            ],
          ),
          body: Container(
            child: Column(
              children: [
                Expanded(
                  child: SmartRefresher(
                    header: WaterDropHeader(),
                    controller: controller.activityRefreshController,
                    onRefresh: () {
                      controller.getActivities();
                    },
                    child: ListView.builder(
                        itemCount:
                            controller.selectedTrip.tripActivitiesDto.length,
                        itemBuilder: (ctx, index) {
                          var _data =
                              controller.selectedTrip.tripActivitiesDto[index];
                          return InkWell(
                            onTap: () {
                              print('activity id is -->${_data.id}');
                              print('activity Local id is -->${_data.localId}');
                            },
                            onLongPress: () {
                              controller.selectedActivity = _data;
                              // Get.dialog(customAlertDialog());
                              customAlertDialog(context,
                                  userType: authController.userModel.userType,
                                  editAction: () {
                                controller.getDataForEditActivity();
                                Get.off(AddTripActivityPage(
                                  type: 'Update',
                                ));
                              }, deleteAction: () {
                                controller.deleteActivity();
                              });
                            },
                            child: tripsActivityCard(
                                updateStatus: _data.updateStatus,
                                status: _data.status,
                                amount: f.format(_data.price),
                                date: DateFormat('dd MMM ,yyyy')
                                    .format(_data.date),
                                description: _data.description,
                                type: _data.transactionType),
                          );
                        }),
                  ),
                ),
                if (controller.selectedTrip.tripActivitiesDto.length > 0)
                  _bottomTotalCard(controller.selectedTrip.tripActivitiesDto)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bottomTotalCard(List<TripActivitiesDto> activityData) {
    double totalIncome = 0;
    double totalExpanse = 0;
    double totalLoan = 0;
    double totalProfit = 0;
    for (var i = 0; i < activityData.length; i++) {
      if (activityData[i].transactionType == 'Income') {
        totalIncome = totalIncome + activityData[i].price;
      }
      if (activityData[i].transactionType == 'Loan') {
        totalLoan = totalLoan + activityData[i].price;
      }
      if (activityData[i].transactionType == 'Expenses') {
        totalExpanse = totalExpanse + activityData[i].price;
      }
    }
    totalProfit = totalIncome - (totalLoan + totalExpanse);
    return Container(
      // color: Colors.blueAccent,
      // height: 150,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Income',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 12),
                  ),
                ),
                _amoutCard('${totalF.format(totalIncome)}', Colors.green),
                space5,
                Expanded(
                  child: Text(
                    'Total Expanse',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12),
                  ),
                ),
                _amoutCard('${totalF.format(totalExpanse)}', Colors.red),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total Loan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 12),
                  ),
                ),
                _amoutCard('${totalF.format(totalLoan)}', Colors.blue),
                space5,
                Expanded(
                  child: Text(
                    'Total Profit',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 12),
                  ),
                ),
                _amoutCard(totalF.format(totalProfit), Colors.teal),
              ],
            ),
          )
        ],
      ),
    );
  }

  _amoutCard(amount, Color color, {foreColor = Colors.white}) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Center(
              child: Text(
            '$amount',
            style: TextStyle(
                color: foreColor, fontWeight: FontWeight.bold, fontSize: 10),
          )),
        ),
      ),
    );
  }
}
