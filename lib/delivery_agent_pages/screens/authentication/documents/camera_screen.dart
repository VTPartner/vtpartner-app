import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vt_partner/global/global.dart' as glb;

class CameraScreen extends StatefulWidget with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _aadharFront;
  File? _aadharBack;
  CameraController? cameraController;

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      cameraController =
          CameraController(_cameras.first, ResolutionPreset.high);
      await cameraController?.initialize();
      setState(() {}); // Update UI once camera is ready
    }
  }

  Future<void> _uploadImage(File image, bool isFront) async {
    String url = '${glb.serverEndPointImage}/upload';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['driver_id'] = '1';
      request.fields['side'] = isFront ? 'front' : 'back';
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      print("request::$request");
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${isFront ? 'Front' : 'Back'} image uploaded successfully'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload image'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
  }

  File? _previewImage;
  bool _isFrontImage = true;

  void _captureImage(bool isFront) async {
    try {
      XFile picture = await cameraController!.takePicture();
      setState(() {
        _previewImage = File(picture.path);
        _isFrontImage = isFront;
      });
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Aadhar Card'),
      ),
      body: cameraController == null || !cameraController!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: CameraPreview(cameraController!),
                ),
                if (_previewImage != null)
                  Column(
                    children: [
                      Image.file(_previewImage!, height: 200),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_previewImage != null) {
                            await _uploadImage(_previewImage!, _isFrontImage);
                            setState(() {
                              if (_isFrontImage) {
                                _aadharFront = _previewImage;
                              } else {
                                _aadharBack = _previewImage;
                              }
                              _previewImage = null;
                            });
                          }
                        },
                        child: Text("Use This Photo"),
                      ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => _captureImage(true),
                        child: Text("Capture Aadhar Front"),
                      ),
                      ElevatedButton(
                        onPressed: () => _captureImage(false),
                        child: Text("Capture Aadhar Back"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
