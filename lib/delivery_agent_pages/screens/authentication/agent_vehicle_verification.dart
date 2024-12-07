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

class AgentVehicleDocumentVerification extends StatefulWidget {
  const AgentVehicleDocumentVerification({super.key});

  @override
  State<AgentVehicleDocumentVerification> createState() =>
      _AgentVehicleDocumentVerificationState();
}

class _AgentVehicleDocumentVerificationState
    extends State<AgentVehicleDocumentVerification> {
List<DropdownMenuItem<String>> _dropdownItems = [];
  String? _selectedVehicleID;
  String vehicleNo = "";
  String? _selectedFuel;
  bool isLoading = false;
  final List<String> _dropdownItemsFuel = [
    'Diesel',
    'Petrol',
    'CNG',
    'Electrical',
  ];
  TextEditingController vehicleNumberTxtEdit = TextEditingController();

  Future<void> _fetchVehicles() async {
// final data = {
//       'mobile_no': "+91${glb.customer_mobile_no}",
//     };

    // final pref = await SharedPreferences.getInstance();

    setState(() {
      _dropdownItems = [];
    });

    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/all_vehicles', {'category_id': 1});
      if (kDebugMode) {
        // print(response);
      }
      // Check if the response contains 'results' key and parse it
      if (response['results'] != null) {
        List<dynamic> vehicles = response['results'];
        // Map the list of service data into a list of Service objects
        setState(() {
          _dropdownItems = vehicles.map((city) {
            return DropdownMenuItem<String>(
              value: city['vehicle_id'].toString(),
              child: Text(
                city['vehicle_name'],
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
        glb.showToast("No Vehicles Found.");
      } else {
        //glb.showToast("An error occurred: ${e.toString()}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> saveVehicleDetails() async {
    final pref = await SharedPreferences.getInstance();
    vehicleNo = vehicleNumberTxtEdit.text.toString().trim();

    var vehicle_front_photo_url = pref.getString("vehicle_front_photo_url");
    var vehicle_back_photo_url = pref.getString("vehicle_back_photo_url");
    var vehicle_plate_front_photo_url =
        pref.getString("vehicle_plate_front_photo_url");
    var vehicle_plate_back_photo_url =
        pref.getString("vehicle_plate_back_photo_url");
    var rc_photo_url = pref.getString("rc_photo_url");
    var rc_no = pref.getString("rc_no");
    var insurance_photo_url = pref.getString("insurance_photo_url");
    var insurance_no = pref.getString("insurance_no");
    var noc_photo_url = pref.getString("noc_photo_url");
    var noc_no = pref.getString("noc_no");
    var puc_photo_url = pref.getString("puc_photo_url");
    var puc_no = pref.getString("puc_no");

    if (vehicleNo.isEmpty) {
      glb.showToast("Please provide your valid vehicle number");
      return;
    }
    if (_selectedFuel == null || _selectedFuel!.isEmpty) {
      glb.showToast("Please select vehicle fuel type");
      return;
    }

    if (_selectedVehicleID == null || _selectedVehicleID!.isEmpty) {
      glb.showToast(
          "Please select your registration vehicle from the list below. If your vehicle is not listed, we currently not available with this vehicle.");
      return;
    }
    if (vehicle_plate_front_photo_url == null ||
        vehicle_plate_front_photo_url.isEmpty) {
      glb.showToast("Please provide your Vehicle Plate Front Picture");
      return;
    }
    if (vehicle_plate_back_photo_url == null ||
        vehicle_plate_back_photo_url.isEmpty) {
      glb.showToast("Please upload Vehicle Plate Back Picture");
      return;
    }
    if (rc_photo_url == null || rc_photo_url.isEmpty) {
      glb.showToast("Please upload RC Picture");
      return;
    }
    if (rc_no == null || rc_no.isEmpty) {
      glb.showToast("Please upload RC Number");
      return;
    }
    if (vehicle_front_photo_url == null || vehicle_front_photo_url.isEmpty) {
      glb.showToast("Please upload Vehicle Front Picture");
      return;
    }
    if (vehicle_back_photo_url == null || vehicle_back_photo_url.isEmpty) {
      glb.showToast("Please upload Vehicle Back Picture");
      return;
    }

    if (insurance_photo_url == null || insurance_photo_url.isEmpty) {
      glb.showToast("Please upload Insurance picture");
      return;
    }
    if (insurance_no == null || insurance_no.isEmpty) {
      glb.showToast("Please upload Insurance Number");
      return;
    }
    if (noc_photo_url == null || noc_photo_url.isEmpty) {
      glb.showToast("Please upload NOC Picture");
      return;
    }
    if (noc_no == null || noc_no.isEmpty) {
      glb.showToast("Please upload NOC Number");
      return;
    }
    if (puc_photo_url == null || puc_photo_url.isEmpty) {
      glb.showToast("Please upload PUC Certificate Picture");
      return;
    }
    if (puc_no == null || puc_no.isEmpty) {
      glb.showToast("Please upload PUC Number");
      return;
    }

    pref.setString("driver_vehicle_no", vehicleNo);
    pref.setString("driver_vehicle_id", _selectedVehicleID!);
    pref.setString("driver_vehicle_fuel_type", _selectedFuel!);

    Navigator.pushNamed(context, AgentOwnerDetailsRoute);
  }
  

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                height: kHeight,
              ),
              Text(
                "Vehicle Information",
                style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.backgroundColorDark,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium?.fontSize),
                overflow: TextOverflow.visible,
              ),
              Text(
                "Your information is kept confidential and used solely for verification and communication purposes",
                style: nunitoSansStyle.copyWith(
                    color: Colors.grey[800],
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                overflow: TextOverflow.visible,
              ),
              SizedBox(
                height: kHeight + 10,
              ),
              GoogleTextFormField(
                  textEditingController: vehicleNumberTxtEdit,
                  hintText: 'Enter your vehicle number',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Vehicle Number *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleDropdownButton(
                hintText: 'Choose your vehicle fuel type',
                labelText: 'Vehicle Fuel Type *',
                items: _dropdownItemsFuel,
                selectedValue: _selectedFuel,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFuel = newValue;
                  });
                },
              ),
              SizedBox(
                height: kHeight,
              ),
              GoogleDropdownButtonDynamic(
                hintText: "select your vehicle.",
                labelText: 'Vehicle :',
                items: _dropdownItems,
                selectedValue: _selectedVehicleID,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVehicleID = newValue;
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
              documentStyle(
                  () {
                Navigator.pushNamed(context, VehicleImagesUploadRoute);
              }, Icons.car_repair, 'Vehicle Image',
                  'Provide Vehicle front and back images', width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, VehiclePlateImagesUploadRoute);
              }, Icons.calendar_view_day_outlined, 'Vehicle Plate No Image',
                  'Provide Vehicle Plate front and back images', width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, RCUploadRoute);
              },
                  Icons.verified,
                  'Registration Certificate (RC)',
                  'Proof of vehicle ownership and registration',
                  width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, InsuranceUploadRoute);
              }, Icons.verified_user, 'Insurance Certificate',
                  'Valid insurance for the vehicle', width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(() {
                Navigator.pushNamed(context, NOCUploadRoute);
              }, Icons.verified_outlined, 'NOC Certificate',
                  'Valid noc for the vehicle', width),
              // Divider(
              //   color: Colors.grey,
              //   thickness: 0.3,
              //   indent: 30,
              // ),
              // documentStyle(
              //     () {},
              //     Icons.car_crash,
              //     'Fitness Certificate',
              //     'For commercial vehicles, confirming that the vehicle is fit for operation.',
              //     width),
              Divider(
                color: Colors.grey,
                thickness: 0.3,
                indent: 30,
              ),
              documentStyle(
                  () {
                Navigator.pushNamed(context, PUCUploadRoute);
              },
                  Icons.air_rounded,
                  'Pollution Under Control (PUC) Certificate',
                  'Proof that the vehicle meets emission standards.',
                  width),
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
                  saveVehicleDetails();
                  //Navigator.pushNamed(context, AgentHomeScreenRoute);
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

  Material documentStyle(Function onTap, IconData iconData, String title,
      String desc, double width) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: nunitoSansStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: width - 100,
                          child: Text(
                            desc,
                            style: nunitoSansStyle.copyWith(
                                color: Colors.grey, fontSize: 10.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
