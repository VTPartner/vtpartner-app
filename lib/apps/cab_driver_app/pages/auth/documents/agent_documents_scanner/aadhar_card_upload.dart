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

class CabAgentAadharCardUploadScreen extends StatefulWidget {
  const CabAgentAadharCardUploadScreen({super.key});

  @override
  State<CabAgentAadharCardUploadScreen> createState() =>
      _CabAgentAadharCardUploadScreenState();
}

class _CabAgentAadharCardUploadScreenState
    extends State<CabAgentAadharCardUploadScreen> {
  File? _aadharFront;
  File? _aadharBack;
  String? previousAadharFront;
  String? previousAadharBack;
  TextEditingController aadharCardNoTextEdit = TextEditingController();
  CameraController? cameraController;
  bool _isCameraInitialized = false;
  int count = 0;

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousAadharFront = pref.getString("cab_agent_aadhar_front_photo_url");
    previousAadharBack = pref.getString("cab_agent_aadhar_back_photo_url");
    var cab_agent_aadhar_no = pref.getString("cab_agent_aadhar_no");
    if (cab_agent_aadhar_no != null && cab_agent_aadhar_no!.isNotEmpty) {
      aadharCardNoTextEdit.text = cab_agent_aadhar_no;
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
          await pref.setString("cab_agent_aadhar_front_photo_url", retUrl);
        } else {
          await pref.setString("cab_agent_aadhar_back_photo_url", retUrl);
        }

        pref.setString(
            "cab_agent_aadhar_no", aadharCardNoTextEdit.text.toString().trim());
        glb.showToast(
            '${isFront ? 'Front' : 'Back'} image uploaded successfully');
      } else {
        glb.showToast('Failed to upload image');
      }
    } catch (e) {
      glb.showToast('An error occurred: $e');
    }
  }

  Future<void> saveAadharDetails() async {
    var aadharNo = aadharCardNoTextEdit.text.trim();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Check if Aadhar number is provided
    if (aadharNo.isEmpty) {
      glb.showToast("Please provide your Aadhar card number");
      return;
    }

    // Fetch existing data from SharedPreferences
    String? savedAadharNo = pref.getString("cab_agent_aadhar_no");
    previousAadharFront = pref.getString("cab_agent_aadhar_front_photo_url");
    previousAadharBack = pref.getString("cab_agent_aadhar_back_photo_url");

    // Determine if this is a new entry
    bool isNewEntry = savedAadharNo == null &&
            (previousAadharFront == null || previousAadharFront!.isEmpty) ||
        (previousAadharBack == null || previousAadharBack!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _aadharFront != null) &&
        (previousAadharFront == null ||
            _aadharFront != null && _aadharFront!.path != previousAadharFront);
    bool needsBackUpload = (isNewEntry || _aadharBack != null) &&
        (previousAadharBack == null ||
            _aadharBack != null && _aadharBack!.path != previousAadharBack);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_aadharFront == null) {
        glb.showToast("Please select and upload your Aadhar card front image");
        return;
      }
      if (_aadharBack == null) {
        glb.showToast("Please select and upload your Aadhar card back image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _aadharFront != null) {
      await _uploadImage(_aadharFront!, true);
    }

    // Upload back image if necessary
    if (needsBackUpload && _aadharBack != null) {
      await _uploadImage(_aadharBack!, false);
    }

    // Update Aadhar number if it's a new entry or has changed
    if (isNewEntry || savedAadharNo != aadharNo) {
      await pref.setString("cab_agent_aadhar_no", aadharNo);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousAadharFront = pref.getString("cab_agent_aadhar_front_photo_url");
    previousAadharBack = pref.getString("cab_agent_aadhar_back_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry &&
            previousAadharFront != null &&
            previousAadharBack != null) ||
        needsFrontUpload ||
        needsBackUpload ||
        savedAadharNo != aadharNo) {
      glb.showToast("Aadhar details saved successfully");
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
                            _aadharFront = File(picture.path);
                          else
                            _aadharBack = File(picture.path);
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
                        "Upload Aadhar Card Document",
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
                          textEditingController: aadharCardNoTextEdit,
                          hintText: 'Enter your aadhar card no',
                          textInputType: TextInputType.text,
                          labelText: 'Aadhar No *'),
                      SizedBox(
                        height: kHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Aadhar Card Front Photo",
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
                            image: (previousAadharFront != null &&
                                    previousAadharFront!.isNotEmpty &&
                                    _aadharFront == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousAadharFront!),
                                    fit: BoxFit.contain,
                                  )
                                : _aadharFront != null
                                    ? DecorationImage(
                                        image: FileImage(_aadharFront!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousAadharFront != null &&
                                  previousAadharFront!.isNotEmpty)
                              ? null
                              : _aadharFront == null
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
                          "Aadhar Card Back Photo",
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
                            image: (previousAadharBack != null &&
                                    previousAadharBack!.isNotEmpty &&
                                    _aadharBack == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousAadharBack!),
                                    fit: BoxFit.contain,
                                  )
                                : _aadharBack != null
                                    ? DecorationImage(
                                        image: FileImage(_aadharBack!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousAadharBack != null &&
                                  previousAadharBack!.isNotEmpty)
                              ? null
                              : _aadharBack == null
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
                          saveAadharDetails();
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
