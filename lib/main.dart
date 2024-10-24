import 'package:flutter/material.dart';
import 'my_day.dart';

void main() {
  runApp(MaterialApp(
    home: MyDayScreen(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
  ));
}
