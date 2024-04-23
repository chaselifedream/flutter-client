import 'package:flutter/material.dart';

const String placeholderProfileUrl =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQLcctnT4T7yHNAj23_ekdZoIrK2_nMZI_3LQ&usqp=CAU';
final ThemeData appTheme = ThemeData(
    //primarySwatch: Colors.yellow,
    // Const constructor creates a "canonicalized" instance
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontFamily: 'Corben',
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.white,
    ));
