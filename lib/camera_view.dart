import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:eye_face_detection/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key key,
    this.isSleeping,
    this.isYawning,
    this.customPaint,
    this.onImage,
    this.initialDirection,
  }) : super(key: key);
  final Text isSleeping;
  final Text isYawning;
  final CustomPaint customPaint;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController _controller;
  int _cameraIndex = 0;
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    _startLiveFeed();
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller =
        CameraController(camera, ResolutionPreset.low, enableAudio: false);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.startImageStream(_processCameraImage);
      setState(() {});
    });
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;
    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width);
      },
    ).toList();
    final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData);
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    widget.onImage(inputImage);
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    // _controller = null;
  }

  @override
  void dispose() {
    _startLiveFeed();
    super.dispose();
  }

  Widget _liveFeedBody() {
    if (_controller?.value?.isInitialized == false) {
      return Container(color: Colors.red, child: CircularProgressIndicator());
    }
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller),
          if (widget.customPaint != null) widget.customPaint,
        ],
      ),
    );
  }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0) {
      _cameraIndex = 1;
    } else {
      _cameraIndex = 0;
    }
    await _stopLiveFeed();
    await _startLiveFeed();
  }

  Widget _floatingActionButton() {
    if (cameras.length == 1) return null;
    return Container(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Icons.flip_camera_ios_outlined,
            size: 40,
          ),
          onPressed: _switchLiveCamera,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20, child: widget.isSleeping),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: const Text(
              "Keep your face inside the frame",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: DottedBorder(
              child: ClipOval(
                child: _liveFeedBody(),
              ),
              borderType: BorderType.Oval,
              padding: EdgeInsets.all(6),
              strokeWidth: 2,
              color: Colors.grey[500],
              dashPattern: [8, 4],
            ),
          ),
          SizedBox(height: 20, child: widget.isYawning),
        ],
      ),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
