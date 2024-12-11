import 'package:flutter/material.dart';

class OtherContent extends StatelessWidget {
  const OtherContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Other'),
      ),
      body: const Center(
        child: Text('Other Screen'),
      ),
    );
  }
}
