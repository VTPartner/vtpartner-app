import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_drop_down_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'package:vt_partner/global/global.dart' as glb;

class JcbCraneDriverAgentDocumentVerificationScreen extends StatefulWidget {
  const JcbCraneDriverAgentDocumentVerificationScreen({super.key});

  @override
  State<JcbCraneDriverAgentDocumentVerificationScreen> createState() =>
      _JcbCraneDriverAgentDocumentVerificationScreenState();
}

class _JcbCraneDriverAgentDocumentVerificationScreenState
    extends State<JcbCraneDriverAgentDocumentVerificationScreen> {
  String? _selectedGender;
  bool isLoading = false;
  final List<String> _dropdownItemsGender = [
    'Male',
    'Female',
    'Other',
  ];
  String? _selectedCityID;
  String driverName = "", driverAddress = "";
  List<DropdownMenuItem<String>> _dropdownItems = [];
  TextEditingController addressTxtEdit = TextEditingController();
  TextEditingController nameTxtEdit = TextEditingController();

  Future<void> _fetchCities() async {
// final data = {
//       'mobile_no': "+91${glb.customer_mobile_no}",
//     };

    // final pref = await SharedPreferences.getInstance();

    setState(() {
      _dropdownItems = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/all_cities', {});
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> cities = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          _dropdownItems = cities.map((city) {
            return DropdownMenuItem<String>(
              value: city['city_id'].toString(),
              child: Text(
                city['city_name'],
                style: nunitoSansStyle.copyWith(
                  // color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            );
          }).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (e.toString().contains("No Data Found")) {
        glb.showToast("No Cities Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> saveDriverDetails() async {
    final pref = await SharedPreferences.getInstance();
    driverName = nameTxtEdit.text.toString().trim();
    driverAddress = addressTxtEdit.text.toString().trim();
    var jcb_crane_driver_agent_aadhar_front_photo_url =
        pref.getString("jcb_crane_driver_agent_aadhar_front_photo_url");
    var jcb_crane_driver_agent_aadhar_back_photo_url =
        pref.getString("jcb_crane_driver_agent_aadhar_back_photo_url");
    var jcb_crane_driver_agent_aadhar_no =
        pref.getString("jcb_crane_driver_agent_aadhar_no");
    var jcb_crane_driver_agent_license_front_photo_url =
        pref.getString("jcb_crane_driver_agent_license_front_photo_url");
    var jcb_crane_driver_agent_license_back_photo_url =
        pref.getString("jcb_crane_driver_agent_license_back_photo_url");
    var jcb_crane_driver_agent_license_no =
        pref.getString("jcb_crane_driver_agent_license_no");
    var jcb_crane_driver_agent_pan_no =
        pref.getString("jcb_crane_driver_agent_pan_no");
    var jcb_crane_driver_agent_pan_front_photo_url =
        pref.getString("jcb_crane_driver_agent_pan_front_photo_url");
    var jcb_crane_driver_agent_pan_back_photo_url =
        pref.getString("jcb_crane_driver_agent_pan_back_photo_url");
    var jcb_crane_driver_agent_selfie_photo_url =
        pref.getString("jcb_crane_driver_agent_selfie_photo_url");

    if (driverName.isEmpty) {
      glb.showToast("Please provide your full name");
      return;
    }
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      glb.showToast("Please select your gender");
      return;
    }
    if (driverAddress.isEmpty) {
      glb.showToast("Please provide your full address");
      return;
    }

    if (_selectedCityID == null || _selectedCityID!.isEmpty) {
      glb.showToast(
          "Please select your registration city from the list below. If your city is not listed, we currently not available in your city.");
      return;
    }
    if (jcb_crane_driver_agent_license_front_photo_url == null ||
        jcb_crane_driver_agent_license_front_photo_url.isEmpty) {
      glb.showToast("Please upload Driving License Front Picture");
      return;
    }
    if (jcb_crane_driver_agent_license_back_photo_url == null ||
        jcb_crane_driver_agent_license_back_photo_url.isEmpty) {
      glb.showToast("Please upload Driving License Back Picture");
      return;
    }
    if (jcb_crane_driver_agent_license_no == null ||
        jcb_crane_driver_agent_license_no.isEmpty) {
      glb.showToast("Please upload Driving License Number");
      return;
    }
    if (jcb_crane_driver_agent_aadhar_front_photo_url == null ||
        jcb_crane_driver_agent_aadhar_front_photo_url.isEmpty) {
      glb.showToast("Please upload Aadhar Front Picture");
      return;
    }
    if (jcb_crane_driver_agent_aadhar_back_photo_url == null ||
        jcb_crane_driver_agent_aadhar_back_photo_url.isEmpty) {
      glb.showToast("Please upload Aadhar Back Picture");
      return;
    }
    if (jcb_crane_driver_agent_aadhar_no == null ||
        jcb_crane_driver_agent_aadhar_no.isEmpty) {
      glb.showToast("Please provide your Aadhar Number");
      return;
    }
    if (jcb_crane_driver_agent_pan_no == null ||
        jcb_crane_driver_agent_pan_no.isEmpty) {
      glb.showToast("Please upload PAN Number");
      return;
    }
    if (jcb_crane_driver_agent_pan_front_photo_url == null ||
        jcb_crane_driver_agent_pan_front_photo_url.isEmpty) {
      glb.showToast("Please upload PAN Front Picture");
      return;
    }
    if (jcb_crane_driver_agent_pan_back_photo_url == null ||
        jcb_crane_driver_agent_pan_back_photo_url.isEmpty) {
      glb.showToast("Please upload PAN Back Picture");
      return;
    }
    if (jcb_crane_driver_agent_selfie_photo_url == null ||
        jcb_crane_driver_agent_selfie_photo_url.isEmpty) {
      glb.showToast("Please upload your selfie");
      return;
    }

    pref.setString("jcb_crane_driver_agent_driver_name", driverName);
    pref.setString("jcb_crane_driver_agent_driver_address", driverAddress);
    pref.setString("jcb_crane_driver_agent_driver_city_id", _selectedCityID!);
    pref.setString("jcb_crane_driver_agent_driver_gender", _selectedGender!);

    Navigator.pushNamed(context, AgentVehicleDocumentVerificationRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                "Driver Information",
                style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.backgroundColorDark,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium?.fontSize),
                overflow: TextOverflow.visible,
              ),
              Text(
                "Note: Your information is kept confidential and used solely for verification and communication purposes.\n Please register only if you are the owner of the Goods Vehicle.",
                style: nunitoSansStyle.copyWith(
                    color: Colors.grey[800],
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                overflow: TextOverflow.visible,
              ),
              SizedBox(
                height: kHeight + 10,
              ),
              GoogleTextFormField(
                  textEditingController: nameTxtEdit,
                  hintText: 'Enter your full name as per document',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Full Name *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleDropdownButton(
                hintText: 'Choose your gender',
                labelText: 'Gender *',
                items: _dropdownItemsGender,
                selectedValue: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  textEditingController: addressTxtEdit,
                  hintText: 'Enter your full address as per document',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Full Address *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleDropdownButtonDynamic(
                hintText:
                    "We currently do not offer services in locations not listed.",
                labelText: 'Register for City :',
                items: _dropdownItems,
                selectedValue: _selectedCityID,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCityID = newValue;
                  });
                },
              ),
              SizedBox(
                height: kHeight,
              ),
              Row(
                children: [
                  HeadingText(title: 'Upload the required documents'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '*',
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 14.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: kHeight,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, CabAgentDrivingLicenseUploadRoute);
              }, Icons.fire_truck_outlined, 'Driving License Photo'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                //On Click open new screen
                Navigator.pushNamed(context, CabAgentAadharCardUploadRoute);
              }, Icons.person_3, 'Aadhar Card [ Owner ]'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, CabAgentPanCardUploadRoute);
              }, Icons.tab_unselected_sharp, 'PAN Card [ Owner ]'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, CabAgentSelfieUploadRoute);
              }, Icons.camera, 'Selfie'),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              SizedBox(
                height: kHeight + 100,
              ),
            ],
          ),
        ),
      )),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  saveDriverDetails();
                  // Navigator.pushNamed(
                  //     context, AgentVehicleDocumentVerificationRoute);
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
                              'Continue',
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
      ),
    );
  }

  Material documentStyle(Function onTap, IconData iconData, String title) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    iconData,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      title,
                      style: nunitoSansStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
