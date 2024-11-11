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

class DrivingLicenseUploadScreen extends StatefulWidget {
  const DrivingLicenseUploadScreen({super.key});

  @override
  State<DrivingLicenseUploadScreen> createState() =>
      _DrivingLicenseUploadScreenState();
}

class _DrivingLicenseUploadScreenState
    extends State<DrivingLicenseUploadScreen> {
  File? _licenseFront;
  File? _licenseBack;
  String? previousLicenseFront;
  String? previousLicenseBack;
  TextEditingController licenseNoTextEdit = TextEditingController();
  CameraController? cameraController;
  bool _isCameraInitialized = false;

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousLicenseFront = pref.getString("license_front_photo_url");
    previousLicenseBack = pref.getString("license_back_photo_url");
    var license_no = pref.getString("license_no");
    if (license_no != null && license_no!.isNotEmpty) {
      licenseNoTextEdit.text = license_no;
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
          await pref.setString("license_front_photo_url", retUrl);
        } else {
          await pref.setString("license_back_photo_url", retUrl);
        }

        pref.setString("license_no", licenseNoTextEdit.text.toString().trim());
        glb.showToast(
            '${isFront ? 'Front' : 'Back'} image uploaded successfully');
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
                          if (type == "front")
                            _licenseFront = File(picture.path);
                          else
                            _licenseBack = File(picture.path);
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

  Future<void> saveLicenseDetails() async {
    var licenseNo = licenseNoTextEdit.text.trim();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Check if License number is provided
    if (licenseNo.isEmpty) {
      glb.showToast("Please provide your Driving License number");
      return;
    }

    // Fetch existing data from SharedPreferences
    String? savedLicenseNo = pref.getString("license_no");
    previousLicenseFront = pref.getString("license_front_photo_url");
    previousLicenseBack = pref.getString("license_back_photo_url");

    // Determine if this is a new entry
    bool isNewEntry = savedLicenseNo == null &&
            (previousLicenseFront == null || previousLicenseFront!.isEmpty) ||
        (previousLicenseBack == null || previousLicenseBack!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _licenseFront != null) &&
        (previousLicenseFront == null ||
            _licenseFront != null &&
                _licenseFront!.path != previousLicenseFront);
    bool needsBackUpload = (isNewEntry || _licenseBack != null) &&
        (previousLicenseBack == null ||
            _licenseBack != null && _licenseBack!.path != previousLicenseBack);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_licenseFront == null) {
        glb.showToast(
            "Please select and upload your Driving License front image");
        return;
      }
      if (_licenseBack == null) {
        glb.showToast(
            "Please select and upload your Driving License back image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _licenseFront != null) {
      await _uploadImage(_licenseFront!, true);
    }

    // Upload back image if necessary
    if (needsBackUpload && _licenseBack != null) {
      await _uploadImage(_licenseBack!, false);
    }

    // Update License number if it's a new entry or has changed
    if (isNewEntry || savedLicenseNo != licenseNo) {
      await pref.setString("license_no", licenseNo);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousLicenseFront = pref.getString("license_front_photo_url");
    previousLicenseBack = pref.getString("license_back_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry &&
            previousLicenseFront != null &&
            previousLicenseBack != null) ||
        needsFrontUpload ||
        needsBackUpload ||
        savedLicenseNo != licenseNo) {
      glb.showToast("License details saved successfully");
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
                        "Upload Driving License Details",
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
                          hintText: 'Enter your driving license no',
                          textEditingController: licenseNoTextEdit,
                          textInputType: TextInputType.text,
                          labelText: 'Driving License No *'),
                      SizedBox(
                        height: kHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Driving License Front Photo",
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
                            image: (previousLicenseFront != null &&
                                    previousLicenseFront!.isNotEmpty &&
                                    _licenseFront == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousLicenseFront!),
                                    fit: BoxFit.contain,
                                  )
                                : _licenseFront != null
                                    ? DecorationImage(
                                        image: FileImage(_licenseFront!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousLicenseFront != null &&
                                  previousLicenseFront!.isNotEmpty)
                              ? null
                              : _licenseFront == null
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
                          "Driving License Back Photo",
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
                            image: (previousLicenseBack != null &&
                                    previousLicenseBack!.isNotEmpty &&
                                    _licenseBack == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousLicenseBack!),
                                    fit: BoxFit.contain,
                                  )
                                : _licenseBack != null
                                    ? DecorationImage(
                                        image: FileImage(_licenseBack!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousLicenseBack != null &&
                                  previousLicenseBack!.isNotEmpty)
                              ? null
                              : _licenseBack == null
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
                          saveLicenseDetails();
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
