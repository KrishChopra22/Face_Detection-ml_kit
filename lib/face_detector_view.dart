import 'package:camera/camera.dart';
import 'package:eye_face_detection/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorView extends StatefulWidget {
  FaceDetectorView({Key key}) : super(key: key);
  String alertSleepingText = "Not Sleeping";
  String alertYawningText = "Not Yawning";

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
          enableClassification: true,
          enableContours: true,
          performanceMode: FaceDetectorMode.accurate));
  bool isBusy = false;
  CustomPaint customPaint;
  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    if (faces.isNotEmpty && faces[0].smilingProbability != null) {
      final double smileProb = faces[0].smilingProbability;
      print("Smile Prob = $smileProb");

      double averageEyeOpenProb =
          (faces[0].leftEyeOpenProbability + faces[0].rightEyeOpenProbability) /
              2.0;
      if (averageEyeOpenProb < 0.6) {
        widget.alertSleepingText = "Driver is feeling drowsy";
        print("\n........SLEEPING........\n");
      }
      if (0.03 < smileProb &&
          smileProb < 0.07 &&
          faces[0].leftEyeOpenProbability < 0.85 &&
          faces[0].rightEyeOpenProbability < 0.85) {
        widget.alertYawningText = "Driver is Yawning";
      }
      // Rect.fromLTRB(
      //   faces[0].boundingBox.left * 4,
      //   faces[0].boundingBox.top * 6,
      //   faces[0].boundingBox.right * 4,
      //   faces[0].boundingBox.bottom * 6,
      // );
      isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: customPaint,
      onImage: (inputImage) {
        processImage(inputImage);
      },
      isSleeping: Text(widget.alertSleepingText,
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      isYawning: Text(widget.alertYawningText,
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      initialDirection: CameraLensDirection.front,
    );
  }
}
