import 'package:flutter/material.dart';
import 'form_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Form Input Flutter MySQL',
    theme: ThemeData(
      primarySwatch: Colors.teal,
    ),
    home: FormPage(),
  ));
}
