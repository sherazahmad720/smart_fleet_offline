import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_fleet/controllers/trip_controller.dart';
import 'package:smart_fleet/widgets/common_widgets.dart';

class AddTripPage extends StatelessWidget {
  final String type;
  AddTripPage({this.type});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(type == 'AddNew' ? 'Add Trip' : 'Update Trip'),
        ),
        body: GetBuilder<TripController>(
          builder: (controller) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: controller.tripFormkey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        customInputTextfield(
                            controller: controller.tripTitleController,
                            label: 'Title',
                            validator: controller.validator,
                            onSave: (val) {
                              controller.tripTitle = val;
                            }),
                        space10,
                        customInputTextfield(
                            controller: controller.tripDescriptionController,
                            label: 'Description',
                            onSave: (val) {
                              controller.tripDescription = val;
                            },
                            validator: controller.validator),
                        space10,
                        customInputTextfield(
                            controller: controller.tripFromController,
                            label: 'From',
                            onSave: (val) {
                              controller.tripFrom = val;
                            },
                            validator: controller.validator),
                        space10,
                        customInputTextfield(
                            controller: controller.tripToController,
                            label: 'To',
                            onSave: (val) {
                              controller.tripTo = val;
                            },
                            validator: controller.validator),
                        space10,
                        customInputTextfield(
                            controller: controller.tripAmountController,
                            label: 'Trip Amount',
                            onSave: (val) {
                              controller.tripAmount = double.parse(val);
                            },
                            validator: controller.amountValidator),
                        space10,
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
                                Text('Start Date'),
                                Text(DateFormat('dd MMM ,yyyy')
                                    .format(controller.startDate)),
                                IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext builder) {
                                            return Container(
                                              height: MediaQuery.of(context)
                                                      .copyWith()
                                                      .size
                                                      .height /
                                                  3,
                                              color: Colors.white,
                                              child: CupertinoDatePicker(
                                                mode: CupertinoDatePickerMode
                                                    .date,
                                                onDateTimeChanged: (picked) {
                                                  controller.startDate = picked;
                                                  controller.update();
                                                },
                                                initialDateTime:
                                                    controller.startDate,
                                                minimumYear: 2000,
                                                maximumYear: 2025,
                                              ),
                                            );
                                          });
                                    })
                              ],
                            ),
                          ),
                        ),
                        // space10,
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
                        //         Text('End Date'),
                        //         Text(DateFormat('dd MMM ,yyyy')
                        //             .format(controller.endData)),
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
                        //                           controller.endData = picked;
                        //                           controller.update();
                        //                         },
                        //                         initialDateTime:
                        //                             controller.endData,
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
                        space10,
                        ElevatedButton(
                            onPressed: () {
                              type == "AddNew"
                                  ? controller.saveTrip()
                                  : controller.updateTrip();
                            },
                            child: Text(
                                type == "AddNew" ? 'Save Trip' : 'Update Trip'))
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
