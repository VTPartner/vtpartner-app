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

class VehicleNOCUpload extends StatefulWidget {
  const VehicleNOCUpload({super.key});

  @override
  State<VehicleNOCUpload> createState() => _VehicleNOCUploadState();
}

class _VehicleNOCUploadState extends State<VehicleNOCUpload> {
  File? _nocImage;
  String? previousNOC;
  String? previousNOCNo;
  CameraController? cameraController;
  bool _isCameraInitialized = false;
  TextEditingController textInput = TextEditingController();

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousNOC = pref.getString("noc_photo_url");
    previousNOCNo = pref.getString("noc_no");
    if (previousNOCNo != null && previousNOCNo!.isNotEmpty) {
      textInput.text = previousNOCNo!;
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
        await pref.setString("noc_photo_url", retUrl);

        glb.showToast('NOC image uploaded successfully');
      } else {
        glb.showToast('Failed to upload image');
      }
    } catch (e) {
      glb.showToast('An error occurred: $e');
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
                          _nocImage = File(picture.path);
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

  Future<void> saveRCDetails() async {
    var nocNo = textInput.text.trim();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Check if Aadhar number is provided
    if (nocNo.isEmpty) {
      glb.showToast("Please provide your NOC number");
      return;
    }

    // Fetch existing data from SharedPreferences
    String? savedNOCNo = pref.getString("noc_no");
    previousNOC = pref.getString("noc_photo_url");

    // Determine if this is a new entry
    bool isNewEntry =
        savedNOCNo == null && (previousNOC == null || previousNOC!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _nocImage != null) &&
        (previousNOC == null ||
            _nocImage != null && _nocImage!.path != previousNOC);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_nocImage == null) {
        glb.showToast("Please select and upload your NOC image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _nocImage != null) {
      await _uploadImage(_nocImage!, true);
    }

    // Update Aadhar number if it's a new entry or has changed
    if (isNewEntry || savedNOCNo != nocNo) {
      await pref.setString("noc_no", nocNo);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousNOC = pref.getString("noc_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry && previousNOC != null) ||
        needsFrontUpload ||
        savedNOCNo != nocNo) {
      glb.showToast("NOC details saved successfully");
      Navigator.pop(context);
    }
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
                        "Upload No Objection Certificate [ NOC ] Details ",
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
                        height: kHeight,
                      ),
                      GoogleTextFormField(
                          textEditingController: textInput,
                          hintText: 'Enter your noc no',
                          textInputType: TextInputType.text,
                          labelText: 'NOC No *'),
                      SizedBox(
                        height: kHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Upload NOC Certificate Image",
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
                            image: (previousNOC != null && _nocImage == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousNOC!),
                                    fit: BoxFit.contain,
                                  )
                                : _nocImage != null
                                    ? DecorationImage(
                                        image: FileImage(_nocImage!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: previousNOC != null
                              ? null
                              : _nocImage == null
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
                          saveRCDetails();
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
