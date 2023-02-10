import 'package:eye_face_detection/face_detector_view.dart';
import 'package:flutter/material.dart';

class DriveScreen extends StatelessWidget {
  const DriveScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Monitoring System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: FaceDetectorView(),
    );
  }
}
