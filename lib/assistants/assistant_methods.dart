import 'package:geolocator/geolocator.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/contact_model.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/models/pickup_location_map_direction.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String humanReadableAddress = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(apiUrl);
    if (response != "Error") {
      humanReadableAddress = response["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updateCustomerCurrentLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<String> mapLocationUsingFromLatLng(
      double lat, double lng, context) async {
    String humanReadableAddress = "", placeId = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(apiUrl);

    if (response != "Error") {
      humanReadableAddress = response["results"][0]["formatted_address"];
      placeId = response["results"][0]["place_id"];
      // print("Map Location Result ::$placeId");
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = lat;
      userPickUpAddress.locationLongitude = lng;
      userPickUpAddress.locationId = placeId;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<String> mapDropLocationUsingFromLatLng(
      double lat, double lng, context) async {
    String humanReadableAddress = "", placeId = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(apiUrl);

    if (response != "Error") {
      humanReadableAddress = response["results"][0]["formatted_address"];
      placeId = response["results"][0]["place_id"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = lat;
      userPickUpAddress.locationLongitude = lng;
      userPickUpAddress.locationId = placeId;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOfLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static saveSenderContactDetails(
      String contactName, String contactNumber, context) {
    if (contactName.isNotEmpty && contactNumber.isNotEmpty) {
      ContactModel senderContactDetails = ContactModel();
      senderContactDetails.contactName = contactName;
      senderContactDetails.contactNumber = contactNumber;

      Provider.of<AppInfo>(context, listen: false)
          .updateSenderContactDetails(senderContactDetails);
    }
  }

  static saveReceiverContactDetails(
      String contactName, String contactNumber, context) {
    if (contactName.isNotEmpty && contactNumber.isNotEmpty) {
      ContactModel receiverContactDetails = ContactModel();
      receiverContactDetails.contactName = contactName;
      receiverContactDetails.contactNumber = contactNumber;

      Provider.of<AppInfo>(context, listen: false)
          .updateReceiverContactDetails(receiverContactDetails);
    }
  }
}
