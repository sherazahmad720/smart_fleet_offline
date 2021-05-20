import 'package:flutter/material.dart';

Widget tripsCard(
    {title,
    isAdmin = false,
    description,
    amount,
    from,
    to,
    startDate,
    endDate,
    userName,
    status,
    updateStatus = '',
    email,
    phoneNo}) {
  return Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(description ?? '', style: TextStyle(fontSize: 12))
                  ],
                ),
              ),
              Text(amount ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundColor: status == 'Online' && updateStatus == ''
                      ? Colors.green
                      : Colors.orange,
                  radius: 5,
                ),
              )
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    // color: Colors.green,
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        Color(0xff373B44),
                        Color(0xff4286f4),
                        // Color(0xff91EAE4),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 16, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        from ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            startDate ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: Center(child: Text('From')))
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Center(child: Text('to'))),
            Expanded(
              flex: 5,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    // color: Colors.orange,
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        Color(0xffcc2b5e),
                        Color(0xff753a88),
                        // Color(0xff91EAE4),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 8, top: 5, bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        to ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            endDate ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
