import 'package:flutter/material.dart';

Widget topMenuItem(BuildContext context, String title, String routeName, [bool selected=false]) {
  Color primaryColor = Theme.of(context).primaryColor;
  Color defaultColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  return Expanded(
    child: InkWell( // Using InkWell to get the splash effect on tap
      onTap: () {
        Navigator.pushReplacementNamed(context, routeName);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0), // Slight vertical padding
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 0.5, // You can adjust as needed
              color: Colors.grey[400]!, // Using a light gray color for the divider
            ),
          ),
        ), // Align text to the center
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.0, // Bigger font size
            fontWeight: FontWeight.bold,
            color: selected ? primaryColor : defaultColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

void showAlertDialog(BuildContext context, String message, [String title = '']) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: title == '' ? Text('Validation Error') : Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('Okay'),
          onPressed: () {
            Navigator.of(ctx).pop(); // Close the alert dialog
          },
        ),
      ],
    ),
  );
}


void settingButtonAlert(BuildContext context, List<Widget> widgets, {double containerHeight = 100}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Container(
        height: containerHeight,
        child: Column(
          children: widgets,
        ),
      ),
      // actions: <Widget>[
      //   TextButton(
      //     child: Text('close'),
      //     onPressed: () {
      //       Navigator.of(ctx).pop(); // Close the alert dialog
      //     },
      //   ),
      // ],
    ),
  );
}