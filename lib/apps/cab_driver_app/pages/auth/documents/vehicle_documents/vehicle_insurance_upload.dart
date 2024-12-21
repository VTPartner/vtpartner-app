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

class CabAgentVehicleInsuranceUpload extends StatefulWidget {
  const CabAgentVehicleInsuranceUpload({super.key});

  @override
  State<CabAgentVehicleInsuranceUpload> createState() =>
      _CabAgentVehicleInsuranceUploadState();
}

class _CabAgentVehicleInsuranceUploadState
    extends State<CabAgentVehicleInsuranceUpload> {
  File? _insuranceImage;
  String? previousInsurance;
  String? previousInsuranceNo;
  CameraController? cameraController;
  bool _isCameraInitialized = false;
  TextEditingController textInput = TextEditingController();

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousInsurance = pref.getString("cab_agent_insurance_photo_url");
    previousInsuranceNo = pref.getString("cab_agent_insurance_no");
    if (previousInsuranceNo != null && previousInsuranceNo!.isNotEmpty) {
      textInput.text = previousInsuranceNo!;
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
        await pref.setString("cab_agent_insurance_photo_url", retUrl);

        glb.showToast('Insurance image uploaded successfully');
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
                          _insuranceImage = File(picture.path);
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

  Future<void> saveInsuranceDetails() async {
    var insuranceNo = textInput.text.trim();
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Check if Aadhar number is provided
    if (insuranceNo.isEmpty) {
      glb.showToast("Please provide your Insurance number");
      return;
    }

    // Fetch existing data from SharedPreferences
    String? savedInsuranceNo = pref.getString("cab_agent_insurance_no");
    previousInsurance = pref.getString("cab_agent_insurance_photo_url");

    // Determine if this is a new entry
    bool isNewEntry = savedInsuranceNo == null &&
        (previousInsurance == null || previousInsurance!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _insuranceImage != null) &&
        (previousInsurance == null ||
            _insuranceImage != null &&
                _insuranceImage!.path != previousInsurance);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_insuranceImage == null) {
        glb.showToast("Please select and upload your insurance image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _insuranceImage != null) {
      await _uploadImage(_insuranceImage!, true);
    }

    // Update Aadhar number if it's a new entry or has changed
    if (isNewEntry || savedInsuranceNo != insuranceNo) {
      await pref.setString("cab_agent_insurance_no", insuranceNo);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousInsurance = pref.getString("cab_agent_insurance_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry && previousInsurance != null) ||
        needsFrontUpload ||
        savedInsuranceNo != insuranceNo) {
      glb.showToast("Insurance details saved successfully");
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
                        "Upload Insurance Details ",
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
                          hintText: 'Enter your insurance no',
                          textInputType: TextInputType.text,
                          labelText: 'Insurance No *'),
                      SizedBox(
                        height: kHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Upload Insurance Certificate",
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
                            image: (previousInsurance != null &&
                                    _insuranceImage == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousInsurance!),
                                    fit: BoxFit.contain,
                                  )
                                : _insuranceImage != null
                                    ? DecorationImage(
                                        image: FileImage(_insuranceImage!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: previousInsurance != null
                              ? null
                              : _insuranceImage == null
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
                          saveInsuranceDetails();
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
