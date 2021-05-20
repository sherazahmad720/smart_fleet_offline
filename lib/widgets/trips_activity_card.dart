import 'package:flutter/material.dart';

Widget tripsActivityCard(
    {description, amount, date, type, status = true, updateStatus = ''}) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(description ?? '',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Text(amount ?? '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: type == 'Loan'
                          ? Colors.blue
                          : type == 'Income'
                              ? Colors.green
                              : Colors.red))
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              // flex: 2,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                    // color: Colors.green,
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: type == 'Loan'
                            ? [
                                Color(0xff591291),
                                Color(0xff5e40ac),
                              ]
                            : type == 'Income'
                                ? [
                                    Color(0xff0bca5e),
                                    Color(0xff4ac03c),
                                  ]
                                : [
                                    Color(0xffAA0606),
                                    Color(0xff606D14),
                                  ]),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 16, top: 5, bottom: 5),
                  child: Text(
                    type ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(date),
                  ],
                ))
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 5,
                backgroundColor: status == 'Online' && updateStatus == ''
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ],
    ),
  );
}
