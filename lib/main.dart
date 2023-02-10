import 'package:eye_face_detection/drive_screen.dart';
import 'package:eye_face_detection/face_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.microphone.request();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DriveScreen()))
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: MediaQuery.of(context).size.width * 0.2,
                ),
                shape: const StadiumBorder()),
            child: const Text(
              "Open Camera",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
