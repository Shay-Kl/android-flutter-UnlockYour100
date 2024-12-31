import 'package:flutter/material.dart';

enum AppColor {
  none(Colors.transparent),
  red(Colors.red),
  green(Colors.green),
  blue(Colors.blue),
  yellow(Colors.yellow);

  final Color color;

  const AppColor(this.color);
}

//usage examples
//for (var appColor in AppColor.values) {
//    print('AppColor: ${appColor.name}, Color: ${appColor.color}');
//}

//AppColor: red, Color: Color(0xffff0000)
//AppColor: green, Color: Color(0xff00ff00)
//AppColor: blue, Color: Color(0xff0000ff)
//AppColor: yellow, Color: Color(0xffffff00)

//class MyWidget extends StatelessWidget {
//  final AppColor selectedColor;

//  MyWidget({required this.selectedColor});

//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      color: selectedColor.color,
//      ....



//AppColor selectedColor = AppColor.green;
// Access the index
//print(selectedColor.index); // Output: 2 (because green is the second value)
