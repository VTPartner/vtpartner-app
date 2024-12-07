import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/routings/route_names.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:vt_partner/widgets/google_drop_down_button.dart';
import 'package:vt_partner/widgets/google_textform.dart';
import 'package:vt_partner/widgets/heading_text.dart';
import 'package:vt_partner/widgets/sub_title_text.dart';
import 'package:vt_partner/global/global.dart' as glb;

class VehicleOwnerDetailsScreen extends StatefulWidget {
  const VehicleOwnerDetailsScreen({super.key});

  @override
  State<VehicleOwnerDetailsScreen> createState() =>
      _VehicleOwnerDetailsScreenState();
}

class _VehicleOwnerDetailsScreenState extends State<VehicleOwnerDetailsScreen> {
  String? _selectedCityID;
  bool isLoading = false;
  String ownerName = "", ownerAddress = "", cityName = "", ownerMobileNo = "";
  List<DropdownMenuItem<String>> _dropdownItems = [];
  TextEditingController addressTxtEdit = TextEditingController();
  TextEditingController nameTxtEdit = TextEditingController();
  TextEditingController cityNameTxtEdit = TextEditingController();
  TextEditingController mobileNoTxtEdit = TextEditingController();

  Future<void> saveOwnerDetails() async {
    final pref = await SharedPreferences.getInstance();
    ownerName = nameTxtEdit.text.toString().trim();
    ownerAddress = addressTxtEdit.text.toString().trim();
    cityName = cityNameTxtEdit.text.toString().trim();
    ownerMobileNo = mobileNoTxtEdit.text.toString().trim();
    var owner_selfie_photo_url = pref.getString("owner_selfie_photo_url");

    if (ownerName.isEmpty) {
      glb.showToast("Please provide owner full name");
      return;
    }
    if (ownerAddress.isEmpty) {
      glb.showToast("Please provide owner full address");
      return;
    }
    if (cityName.isEmpty) {
      glb.showToast("Please provide owner City Name");
      return;
    }
    if (ownerMobileNo.isEmpty) {
      glb.showToast("Please provide owner mobile number");
      return;
    }
    if (ownerMobileNo.length != 10) {
      glb.showToast("Please provide valid 10 digits owner mobile number");
      return;
    }
    if (owner_selfie_photo_url == null || owner_selfie_photo_url.isEmpty) {
      glb.showToast("Please upload Owner Photo");
      return;
    }

    pref.setString("owner_name", ownerName);
    pref.setString("owner_address", ownerAddress);
    pref.setString("owner_city_name", cityName);
    pref.setString("owner_mobile_no", ownerMobileNo);
    registerDriverAsync();
    //Navigator.pushNamed(context, AgentHomeScreenRoute);
  }

  Future<void> registerDriverAsync() async {
    setState(() {
      isLoading = true;
    });
    final pref = await SharedPreferences.getInstance();

    //
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var latitude = appInfo.userCurrentLocation?.locationLatitude;
    var longitude = appInfo.userCurrentLocation?.locationLongitude;
    var full_address_current = appInfo.userCurrentLocation?.locationName;
    var pincode = appInfo.userCurrentLocation?.pinCode;

    var goods_driver_id = pref.getString("goods_driver_id");
    var driver_first_name = pref.getString("driver_name");
    var profile_pic = pref.getString("selfie_photo_url");
    var mobile_no = pref.getString("goods_driver_mobno");
    var r_lat = latitude;
    var r_lng = longitude;
    var current_lat = latitude;
    var current_lng = longitude;
    var recent_online_pic = pref.getString("selfie_photo_url");
    var vehicle_id = pref.getString("driver_vehicle_id");
    var city_id = pref.getString("driver_city_id");
    var aadhar_no = pref.getString("aadhar_no");
    var pan_card_no = pref.getString("pan_no");
    var full_address = pref.getString("driver_address");
    var gender = pref.getString("driver_gender");
    var aadhar_card_front = pref.getString("aadhar_front_photo_url");
    var aadhar_card_back = pref.getString("aadhar_back_photo_url");
    var pan_card_front = pref.getString("pan_front_photo_url");
    var pan_card_back = pref.getString("pan_back_photo_url");
    var license_front = pref.getString("license_front_photo_url");
    var license_back = pref.getString("license_back_photo_url");
    var insurance_image = pref.getString("insurance_photo_url");
    var noc_image = pref.getString("noc_photo_url");
    var pollution_certificate_image = pref.getString("puc_photo_url");
    var rc_image = pref.getString("rc_photo_url");
    var vehicle_image = pref.getString("vehicle_front_photo_url");
    var vehicle_plate_image = pref.getString("vehicle_plate_front_photo_url");
    var driving_license_no = pref.getString("license_no");
    var vehicle_plate_no = pref.getString("driver_vehicle_no");
    var rc_no = pref.getString("rc_no");
    var insurance_no = pref.getString("insurance_no");
    var noc_no = pref.getString("noc_no");
    var vehicle_fuel_type = pref.getString("driver_vehicle_fuel_type");
    var owner_name = pref.getString("owner_name");
    var owner_mobile_no = pref.getString("owner_mobile_no");
    var owner_photo_url = pref.getString("owner_selfie_photo_url");
    var owner_address = pref.getString("owner_address");
    var owner_city_name = pref.getString("owner_city_name");

    final data = {
      "goods_driver_id": goods_driver_id,
      "driver_first_name": driver_first_name,
      "profile_pic": profile_pic,
      "mobile_no": mobile_no ?? "${glb.delivery_agent_mobile_no}",
      "r_lat": r_lat,
      "r_lng": r_lng,
      "current_lat": current_lat,
      "current_lng": current_lng,
      "recent_online_pic": recent_online_pic,
      "vehicle_id": vehicle_id,
      "city_id": city_id,
      "aadhar_no": aadhar_no,
      "pan_card_no": pan_card_no,
      "full_address": full_address,
      "gender": gender,
      "aadhar_card_front": aadhar_card_front,
      "aadhar_card_back": aadhar_card_back,
      "pan_card_front": pan_card_front,
      "pan_card_back": pan_card_back,
      "license_front": license_front,
      "license_back": license_back,
      "insurance_image": insurance_image,
      "noc_image": noc_image,
      "pollution_certificate_image": pollution_certificate_image,
      "rc_image": rc_image,
      "vehicle_image": vehicle_image,
      "vehicle_plate_image": vehicle_plate_image,
      "driving_license_no": driving_license_no,
      "vehicle_plate_no": vehicle_plate_no,
      "rc_no": rc_no,
      "insurance_no": insurance_no,
      "noc_no": noc_no,
      "vehicle_fuel_type": vehicle_fuel_type,
      "owner_name": owner_name,
      "owner_mobile_no": owner_mobile_no,
      "owner_photo_url": owner_photo_url,
      "owner_address": owner_address,
      "owner_city_name": owner_city_name
    };
    print("data::$data");
    try {
      final response = await RequestAssistant.postRequest(
          '${glb.serverEndPoint}/goods_driver_registration', data);
      if (kDebugMode) {
        print(response);
      }
      setState(() {
        isLoading = false;
      });
      if (response["message"] != null) {
        Navigator.pushReplacementNamed(context, AgentHomeScreenRoute);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      setState(() {
        isLoading = false;
      });
      //glb.showToast("An error occurred: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    loadDefault();
  }

  loadDefault() async {
    final pref = await SharedPreferences.getInstance();
    var owner_name = pref.getString("owner_name")!;
    var owner_address = pref.getString("owner_address")!;
    var city_name = pref.getString("owner_city_name")!;
    var owner_mobile_no = pref.getString("owner_mobile_no")!;

    if (owner_name.isNotEmpty) {
      nameTxtEdit.text = owner_name;
    }
    if (owner_address.isNotEmpty) {
      addressTxtEdit.text = owner_address;
    }
    if (city_name.isNotEmpty) {
      cityNameTxtEdit.text = city_name;
    }
    if (owner_mobile_no.isNotEmpty) {
      mobileNoTxtEdit.text = owner_mobile_no;
    }
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
                "Owner Information",
                style: nunitoSansStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeClass.backgroundColorDark,
                    fontSize:
                        Theme.of(context).textTheme.displayMedium?.fontSize),
                overflow: TextOverflow.visible,
              ),
              Text(
                "Note: Your information is kept confidential and used solely for verification and communication purposes.\n If you are only the owner add your details.",
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
                  hintText: 'Enter owner full name as per document',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Owner Full Name *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  textEditingController: addressTxtEdit,
                  hintText: 'Enter owner full address as per document',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Owner Full Address *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  textEditingController: cityNameTxtEdit,
                  hintText: 'Enter owner city name as per document',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Owner City Name *'),
              SizedBox(
                height: kHeight,
              ),
              GoogleTextFormField(
                  textEditingController: mobileNoTxtEdit,
                  hintText: 'Enter owner phone number',
                  textInputType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  labelText: 'Owner Phone Number *'),
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
                Navigator.pushNamed(context, OwnerPhotoUploadRoute);
              }, Icons.fire_truck_outlined, 'Owner Photo'),
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        saveOwnerDetails();
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
                                    'Submit',
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
