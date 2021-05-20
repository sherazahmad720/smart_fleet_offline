import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';

class AddTripActivityPage extends StatelessWidget {
  final String type;
  AddTripActivityPage({this.type});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(type == 'AddNew' ? 'Add Activity' : 'Update Activity'),
        ),
        body: GetBuilder<TripController>(
          builder: (controller) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: controller.activityFormkey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.deepOrange)),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Select Type'),
                                DropdownButton(
                                    value: controller.transactionType,
                                    onChanged: (val) {
                                      controller.transactionType = val;
                                      controller.update();
                                    },
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("Loan"),
                                        value: 'Loan',
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Expenses"),
                                        value: 'Expenses',
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Income"),
                                        value: 'Income',
                                      ),
                                    ])
                              ],
                            ),
                          ),
                        ),
                        space10,
                        customInputTextfield(
                            controller:
                                controller.activityDescriptionController,
                            label: 'Description',
                            validator: controller.validator,
                            onSave: (val) {
                              controller.activityDescription = val;
                            }),
                        space10,
                        customInputTextfield(
                            controller: controller.activityAmountController,
                            keyBoardType: TextInputType.number,
                            label: 'Amount',
                            onSave: (val) {
                              controller.activityAmount = double.parse(val);
                            },
                            validator: controller.amountValidator),
                        space10,
                        // Container(
                        //   height: 50,
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(5),
                        //       border: Border.all(color: Colors.deepOrange)),
                        //   child: Padding(
                        //     padding:
                        //         const EdgeInsets.symmetric(horizontal: 8.0),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text('Activity Date'),
                        //         Text(DateFormat('dd MMM ,yyyy')
                        //             .format(controller.activityDate)),
                        //         IconButton(
                        //             icon: Icon(Icons.calendar_today),
                        //             onPressed: () {
                        //               // buildCupertinoDatePicker(
                        //               //     BuildContext context) {
                        //               showModalBottomSheet(
                        //                   context: context,
                        //                   builder: (BuildContext builder) {
                        //                     return Container(
                        //                       height: MediaQuery.of(context)
                        //                               .copyWith()
                        //                               .size
                        //                               .height /
                        //                           3,
                        //                       color: Colors.white,
                        //                       child: CupertinoDatePicker(
                        //                         mode: CupertinoDatePickerMode
                        //                             .date,
                        //                         onDateTimeChanged: (picked) {
                        //                           controller.activityDate =
                        //                               picked;
                        //                           controller.update();
                        //                         },
                        //                         initialDateTime:
                        //                             controller.activityDate,
                        //                         minimumYear: 2000,
                        //                         maximumYear: 2025,
                        //                       ),
                        //                     );
                        //                   });
                        //               // }
                        //             })
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // space10,
                        ElevatedButton(
                            onPressed: () {
                              type == 'AddNew'
                                  ? controller.saveActivity()
                                  : controller.updateActivity();
                            },
                            child: Text(type == 'AddNew'
                                ? 'Save Activity'
                                : 'Update Activity'))
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
