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

class CabAgentVehiclePlateNoUpload extends StatefulWidget {
  const CabAgentVehiclePlateNoUpload({super.key});

  @override
  State<CabAgentVehiclePlateNoUpload> createState() =>
      _CabAgentVehiclePlateNoUploadState();
}

class _CabAgentVehiclePlateNoUploadState
    extends State<CabAgentVehiclePlateNoUpload> {
  File? _vehiclePlateFront;
  File? _vehiclePlateBack;
  String? previousVehiclePlateFront;
  String? previousVehiclePlateBack;

  CameraController? cameraController;
  bool _isCameraInitialized = false;
  int count = 0;

  Future<void> _setupCameraController() async {
    final pref = await SharedPreferences.getInstance();
    previousVehiclePlateFront =
        pref.getString("cab_agent_vehicle_plate_front_photo_url");
    previousVehiclePlateBack =
        pref.getString("cab_agent_vehicle_plate_back_photo_url");

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
          await pref.setString(
              "cab_agent_vehicle_plate_front_photo_url", retUrl);
        } else {
          await pref.setString(
              "cab_agent_vehicle_plate_back_photo_url", retUrl);
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

  Future<void> saveVehiclePlateImageDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Fetch existing data from SharedPreferences

    previousVehiclePlateFront =
        pref.getString("cab_agent_vehicle_plate_front_photo_url");
    previousVehiclePlateBack =
        pref.getString("cab_agent_vehicle_plate_back_photo_url");

    // Determine if this is a new entry
    bool isNewEntry = (previousVehiclePlateFront == null ||
            previousVehiclePlateFront!.isEmpty) ||
        (previousVehiclePlateBack == null || previousVehiclePlateBack!.isEmpty);

    // Check if the front and back images need uploading
    bool needsFrontUpload = (isNewEntry || _vehiclePlateFront != null) &&
        (previousVehiclePlateFront == null ||
            _vehiclePlateFront != null &&
                _vehiclePlateFront!.path != previousVehiclePlateFront);
    bool needsBackUpload = (isNewEntry || _vehiclePlateBack != null) &&
        (previousVehiclePlateBack == null ||
            _vehiclePlateBack != null &&
                _vehiclePlateBack!.path != previousVehiclePlateBack);

    // Show a toast if the front or back image is missing on a new entry
    if (isNewEntry) {
      if (_vehiclePlateFront == null) {
        glb.showToast(
            "Please select and upload your vehicle plate front image");
        return;
      }
      if (_vehiclePlateBack == null) {
        glb.showToast("Please select and upload your vehicle plate back image");
        return;
      }
    }

    // Upload front image if necessary
    if (needsFrontUpload && _vehiclePlateFront != null) {
      await _uploadImage(_vehiclePlateFront!, true);
    }

    // Upload back image if necessary
    if (needsBackUpload && _vehiclePlateBack != null) {
      await _uploadImage(_vehiclePlateBack!, false);
    }

    // Re-fetch saved URLs to confirm successful upload before proceeding
    previousVehiclePlateFront =
        pref.getString("cab_agent_vehicle_plate_front_photo_url");
    previousVehiclePlateBack =
        pref.getString("cab_agent_vehicle_plate_back_photo_url");

    // Show success message and navigate back if data was successfully saved or updated
    if ((isNewEntry &&
            previousVehiclePlateFront != null &&
            previousVehiclePlateBack != null) ||
        needsFrontUpload ||
        needsBackUpload) {
      glb.showToast("Vehicle Plate Images details saved successfully");
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
                            _vehiclePlateFront = File(picture.path);
                          else
                            _vehiclePlateBack = File(picture.path);
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
                        "Upload Vehicle Plate Images",
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
                          "Vehicle Plate Front Photo",
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
                            image: (previousVehiclePlateFront != null &&
                                    previousVehiclePlateFront!.isNotEmpty &&
                                    _vehiclePlateFront == null)
                                ? DecorationImage(
                                    image: NetworkImage(
                                        previousVehiclePlateFront!),
                                    fit: BoxFit.contain,
                                  )
                                : _vehiclePlateFront != null
                                    ? DecorationImage(
                                        image: FileImage(_vehiclePlateFront!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousVehiclePlateFront != null &&
                                  previousVehiclePlateFront!.isNotEmpty)
                              ? null
                              : _vehiclePlateFront == null
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
                          "Vehicle Plate Back Photo",
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
                            image: (previousVehiclePlateBack != null &&
                                    previousVehiclePlateBack!.isNotEmpty &&
                                    _vehiclePlateBack == null)
                                ? DecorationImage(
                                    image:
                                        NetworkImage(previousVehiclePlateBack!),
                                    fit: BoxFit.contain,
                                  )
                                : _vehiclePlateBack != null
                                    ? DecorationImage(
                                        image: FileImage(_vehiclePlateBack!),
                                        fit: BoxFit.contain,
                                      )
                                    : null,
                          ),
                          child: (previousVehiclePlateBack != null &&
                                  previousVehiclePlateBack!.isNotEmpty)
                              ? null
                              : _vehiclePlateBack == null
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
                          saveVehiclePlateImageDetails();
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
