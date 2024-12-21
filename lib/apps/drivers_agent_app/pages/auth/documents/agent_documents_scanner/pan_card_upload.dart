import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vt_partner/global/global.dart' as glb;

class DriverAgentPanCardUploadScreen extends StatefulWidget {
  const DriverAgentPanCardUploadScreen({super.key});

  @override
  State<DriverAgentPanCardUploadScreen> createState() =>
      _DriverAgentPanCardUploadScreenState();
}

class _DriverAgentPanCardUploadScreenState
    extends State<DriverAgentPanCardUploadScreen> {
  File? _panFront;
  File? _panBack;
  String? previousPanFront;
  String? previousPanBack;
  TextEditingController panNoTextEdit = TextEditingController();
  CameraController? cameraController;
  bool _isCameraInitialized = false;

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousPanFront = pref.getString("driver_agent_pan_front_photo_url");
    previousPanBack = pref.getString("driver_agent_pan_back_photo_url");
    var driver_agent_pan_no = pref.getString("driver_agent_pan_no");
    if (driver_agent_pan_no != null && driver_agent_pan_no!.isNotEmpty) {
      panNoTextEdit.text = driver_agent_pan_no;
    }

    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      cameraController =
          CameraController(_cameras.first, ResolutionPreset.high);
      await cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      }); // Update UI once camera is ready
    }
  }

  Future<void> _uploadImage(File image, bool isFront) async {
    final pref = await SharedPreferences.getInstance();
    String url = '${glb.serverEndPointImage}/upload';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      // request.fields['driver_id'] = '1';
      // request.fields['side'] = isFront ? 'front' : 'back';
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      print("request::$request");
      var response = await request.send();
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(await response.stream.bytesToString());
        print("jsonBody::$jsonBody");
        print("jsonBody::${jsonBody["image_url"]}");
        //return jsonBody;
        var retUrl = jsonBody["image_url"];
        if (isFront) {
          await pref.setString("driver_agent_pan_front_photo_url", retUrl);
        } else {
          await pref.setString("driver_agent_pan_back_photo_url", retUrl);
        }

        pref.setString(
            "driver_agent_pan_no", panNoTextEdit.text.toString().trim());
        glb.showToast(
            '${isFront ? 'Front' : 'Back'} image uploaded successfully');
      } else {
        glb.showToast('Failed to upload image');
      }
    } catch (e) {
      glb.showToast('An error occurred: $e');
    }
  }

  Future<void> savePanDetails() async {
    var panNo = panNoTextEdit.text.trim();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Check if License number is provided
    if (panNo.isEmpty) {
      glb.showToast("Please provide your PAN number");
      return;
    }

    // Fetch existing data from SharedPreferences
    String? savedPanNo = pref.getString("driver_agent_pan_no");
    previousPanFront = pref.getString("driver_agent_pan_front_photo_url");
    previousPanBack = pref.getString("driver_agent_pan_back_photo_url");

    // Determine if this is a new entry
    bool isNewEntry = savedPanNo == null &&
            (previousPanFront == null || previousPanFront!.isEmpty) ||
        (previousPanBack == null || previousPanBack!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _panFront != null) &&
        (previousPanFront == null ||
            _panFront != null && _panFront!.path != previousPanFront);
    bool needsBackUpload = (isNewEntry || _panBack != null) &&
        (previousPanBack == null ||
            _panBack != null && _panBack!.path != previousPanBack);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_panFront == null) {
        glb.showToast("Please select and upload your Pan Card front image");
        return;
      }
      if (_panBack == null) {
        glb.showToast("Please select and upload your Pan Card back image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _panFront != null) {
      await _uploadImage(_panFront!, true);
    }

    // Upload back image if necessary
    if (needsBackUpload && _panBack != null) {
      await _uploadImage(_panBack!, false);
    }

    // Update License number if it's a new entry or has changed
    if (isNewEntry || savedPanNo != panNo) {
      await pref.setString("driver_agent_pan_no", panNo);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousPanFront = pref.getString("driver_agent_pan_front_photo_url");
    previousPanBack = pref.getString("driver_agent_pan_back_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry && previousPanFront != null && previousPanBack != null) ||
        needsFrontUpload ||
        needsBackUpload ||
        savedPanNo != panNo) {
      glb.showToast("Pan Card details saved successfully");
      Navigator.pop(context);
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

  void _showCameraPreviewDialog(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              if (_isCameraInitialized) CameraPreview(cameraController!),
              SizedBox(height: 10),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: IconButton(
                    onPressed: () async {
                      try {
                        XFile picture = await cameraController!.takePicture();
                        setState(() {
                          if (type == "front")
                            _panFront = File(picture.path);
                          else
                            _panBack = File(picture.path);
                        });
                        Navigator.of(context).pop(); // Close the dialog
                      } catch (e) {
                        print("Error capturing image: $e");
                      }
                    },
                    icon: Icon(
                      Icons.camera,
                      color: Colors.red,
                      size: 60,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: cameraController == null || !cameraController!.value.isInitialized
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30.0,
                            color: Colors.grey[900],
                          )),
                      SizedBox(
                        height: kHeight - 10,
                      ),
                      Text(
                        "Upload PAN Card Details",
                        style: nunitoSansStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ThemeClass.backgroundColorDark,
                            fontSize: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.fontSize),
                        overflow: TextOverflow.visible,
                      ),
                      Text(
                        "Note: Your information is kept confidential and used solely for verification and communication purposes.",
                        style: nunitoSansStyle.copyWith(
                            color: Colors.grey[800],
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.fontSize),
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(
                        height: kHeight + 10,
                      ),
                      GoogleTextFormField(
                          textEditingController: panNoTextEdit,
                          hintText: 'Enter your pan card no',
                          textInputType: TextInputType.text,
                          labelText: 'PAN No *'),
                      SizedBox(
                        height: kHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "PAN Card Front Photo",
                          textAlign: TextAlign.center,
                          style: nunitoSansStyle.copyWith(
                              color: Colors.grey[800],
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.fontSize),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showCameraPreviewDialog("front"),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: (previousPanFront != null &&
                                    previousPanFront!.isNotEmpty &&
                                    _panFront == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousPanFront!),
                                    fit: BoxFit.contain,
                                  )
                                : _panFront != null
                                    ? DecorationImage(
                                        image: FileImage(_panFront!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousPanFront != null &&
                                  previousPanFront!.isNotEmpty)
                              ? null
                              : _panFront == null
                                  ? Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey)
                                  : null,
                        ),
                      ),
                      SizedBox(
                        height: kHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "PAN Card Back Photo",
                          textAlign: TextAlign.center,
                          style: nunitoSansStyle.copyWith(
                              color: Colors.grey[800],
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.fontSize),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showCameraPreviewDialog("back"),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            image: (previousPanBack != null &&
                                    previousPanBack!.isNotEmpty &&
                                    _panBack == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousPanBack!),
                                    fit: BoxFit.contain,
                                  )
                                : _panBack != null
                                    ? DecorationImage(
                                        image: FileImage(_panBack!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousPanBack != null &&
                                  previousPanBack!.isNotEmpty)
                              ? null
                              : _panBack == null
                                  ? Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey)
                                  : null,
                        ),
                      ),
                      SizedBox(
                        height: kHeight + 100,
                      ),
                    ],
                  ),
                ),
              )),
        bottomSheet: _isCameraInitialized
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          savePanDetails();
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                              color: ThemeClass.facebookBlue,
                              borderRadius: BorderRadius.circular(16.0)),
                          child: Stack(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Update',
                                      style: nunitoSansStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.fontSize),
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null);
  }
}
