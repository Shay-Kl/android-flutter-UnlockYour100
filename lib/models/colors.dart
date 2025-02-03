// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum ColorSchemeKey {
  Default, 
  Group1, 
  Group2, 
  Group3, 
  Group4, 
  Group5, 
  Group6,
  Group7,
  Group8,
  Group9,
  Group10,
  Group11,
}

extension ColorSchemeKeyExtension on ColorSchemeKey {
  Color getColorFromScheme(ColorScheme scheme) {
    if (scheme == ColorScheme.fromSeed(seedColor: Colors.blue)){
      switch (this) {
        case ColorSchemeKey.Default:
          return const Color.fromARGB(255, 255, 255, 255);
        case ColorSchemeKey.Group1:
          return const Color.fromARGB(255, 239, 239, 241);
        case ColorSchemeKey.Group2:
          return const Color.fromARGB(255, 233, 227, 211);
        case ColorSchemeKey.Group3:
          return const Color.fromARGB(255, 250, 175, 169);
        case ColorSchemeKey.Group4:
          return const Color.fromARGB(255, 242, 159, 117);
        case ColorSchemeKey.Group5:
          return const Color.fromARGB(255, 255, 248, 185);
        case ColorSchemeKey.Group6:
          return const Color.fromARGB(255, 226, 246, 211);
        case ColorSchemeKey.Group7:
          return const Color.fromARGB(255, 173, 216, 230);
        case ColorSchemeKey.Group8:
          return const Color.fromARGB(255, 221, 160, 221);
        case ColorSchemeKey.Group9:
          return const Color.fromARGB(255, 240, 128, 128);
        case ColorSchemeKey.Group10:
          return const Color.fromARGB(255, 189, 252, 201);
        case ColorSchemeKey.Group11:
          return const Color.fromARGB(255, 211, 211, 211);
      }
    }
    else {
      switch (this) {
        case ColorSchemeKey.Default:
          return const Color.fromARGB(255, 0, 0, 0);
        case ColorSchemeKey.Group1:
          return const Color.fromARGB(255, 35, 36, 40);
        case ColorSchemeKey.Group2:
          return const Color.fromARGB(255, 75, 68, 58);
        case ColorSchemeKey.Group3:
          return const Color.fromARGB(255, 118, 23, 45);
        case ColorSchemeKey.Group4:
          return const Color.fromARGB(255, 105, 42, 24);
        case ColorSchemeKey.Group5:
          return const Color.fromARGB(255, 124, 74, 3);
        case ColorSchemeKey.Group6:
          return const Color.fromARGB(255, 38, 77, 59);
        case ColorSchemeKey.Group7:
          return const Color.fromARGB(255, 0, 51, 102);
        case ColorSchemeKey.Group8:
          return const Color.fromARGB(255, 68, 0, 68);
        case ColorSchemeKey.Group9:
          return const Color.fromARGB(255, 102, 0, 0);
        case ColorSchemeKey.Group10:
          return const Color.fromARGB(255, 0, 102, 102);
        case ColorSchemeKey.Group11:
          return const Color.fromARGB(255, 85, 107, 47);
      }
    }  
  }

  String toKeyString() => toString().split('.').last;

  static ColorSchemeKey fromKeyString(String key) =>
      ColorSchemeKey.values.firstWhere((e) => e.toKeyString() == key);
}