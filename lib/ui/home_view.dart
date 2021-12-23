import 'package:flutter/material.dart';
import 'package:adas/ui/Settings/adjust_view.dart';
import 'package:adas/ui/detection_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdjustView()),
            );
          },
          child: Text('Adjust'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetectionView()),
            );
          },
          child: Text('Detect'),
        ),
      ],
    );
  }
}
