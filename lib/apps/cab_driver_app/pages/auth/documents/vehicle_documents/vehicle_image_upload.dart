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

class CabAgentVehicleImageUpload extends StatefulWidget {
  const CabAgentVehicleImageUpload({super.key});

  @override
  State<CabAgentVehicleImageUpload> createState() =>
      _CabAgentVehicleImageUploadState();
}

class _CabAgentVehicleImageUploadState
    extends State<CabAgentVehicleImageUpload> {
  File? _vehicleFront;
  File? _vehicleBack;
  String? previousVehicleFront;
  String? previousVehicleBack;

  CameraController? cameraController;
  bool _isCameraInitialized = false;
  int count = 0;

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousVehicleFront = pref.getString("cab_agent_vehicle_front_photo_url");
    previousVehicleBack = pref.getString("cab_agent_vehicle_back_photo_url");

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
          await pref.setString("cab_agent_vehicle_front_photo_url", retUrl);
        } else {
          await pref.setString("cab_agent_vehicle_back_photo_url", retUrl);
        }

        glb.showToast(
            '${isFront ? 'Front' : 'Back'} image uploaded successfully');
      } else {
        glb.showToast('Failed to upload image');
      }
    } catch (e) {
      glb.showToast('An error occurred: $e');
    }
  }

  Future<void> saveVehicleImageDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Fetch existing data from SharedPreferences

    previousVehicleFront = pref.getString("cab_agent_vehicle_front_photo_url");
    previousVehicleBack = pref.getString("cab_agent_vehicle_back_photo_url");

    // Determine if this is a new entry
    bool isNewEntry =
        (previousVehicleFront == null || previousVehicleFront!.isEmpty) ||
            (previousVehicleBack == null || previousVehicleBack!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _vehicleFront != null) &&
        (previousVehicleFront == null ||
            _vehicleFront != null &&
                _vehicleFront!.path != previousVehicleFront);
    bool needsBackUpload = (isNewEntry || _vehicleBack != null) &&
        (previousVehicleBack == null ||
            _vehicleBack != null && _vehicleBack!.path != previousVehicleBack);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_vehicleFront == null) {
        glb.showToast("Please select and upload your vehicle front image");
        return;
      }
      if (_vehicleBack == null) {
        glb.showToast("Please select and upload your vehicle back image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _vehicleFront != null) {
      await _uploadImage(_vehicleFront!, true);
    }

    // Upload back image if necessary
    if (needsBackUpload && _vehicleBack != null) {
      await _uploadImage(_vehicleBack!, false);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousVehicleFront = pref.getString("cab_agent_vehicle_front_photo_url");
    previousVehicleBack = pref.getString("cab_agent_vehicle_back_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry &&
            previousVehicleFront != null &&
            previousVehicleBack != null) ||
        needsFrontUpload ||
        needsBackUpload) {
      glb.showToast("Vehicle Image details saved successfully");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _setupCameraController();
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
                            _vehicleFront = File(picture.path);
                          else
                            _vehicleBack = File(picture.path);
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
                        "Upload Vehicle Images",
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Vehicle Front Photo",
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
                            image: (previousVehicleFront != null &&
                                    previousVehicleFront!.isNotEmpty &&
                                    _vehicleFront == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousVehicleFront!),
                                    fit: BoxFit.contain,
                                  )
                                : _vehicleFront != null
                                    ? DecorationImage(
                                        image: FileImage(_vehicleFront!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousVehicleFront != null &&
                                  previousVehicleFront!.isNotEmpty)
                              ? null
                              : _vehicleFront == null
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
                          "Vehicle Back Photo",
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
                            image: (previousVehicleBack != null &&
                                    previousVehicleBack!.isNotEmpty &&
                                    _vehicleBack == null)
                                ? DecorationImage(
                                    image: NetworkImage(previousVehicleBack!),
                                    fit: BoxFit.contain,
                                  )
                                : _vehicleBack != null
                                    ? DecorationImage(
                                        image: FileImage(_vehicleBack!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousVehicleBack != null &&
                                  previousVehicleBack!.isNotEmpty)
                              ? null
                              : _vehicleBack == null
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
                          saveVehicleImageDetails();
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
