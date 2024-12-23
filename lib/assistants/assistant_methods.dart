import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vt_partner/assistants/request_assistance.dart';
import 'package:vt_partner/customer_pages/models/active_booking_model.dart';
import 'package:vt_partner/global/global.dart';

import 'package:vt_partner/global/map_key.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/contact_model.dart';
import 'package:vt_partner/models/direction_details_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/models/pickup_location_map_direction.dart';
import 'package:vt_partner/customer_pages/models/goods_type_model.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context, bool saveAsPickup) async {
    String humanReadableAddress = "", postalCode = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(apiUrl);
    if (response != "Error") {
      humanReadableAddress = response["results"][0]["formatted_address"];
      for (var component in response["results"][0]["address_components"]) {
        if (component["types"].contains("postal_code")) {
          postalCode = component["long_name"];
          break;
        }
      }
      print("postalCode::$postalCode");
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.pinCode = postalCode;
      userPickUpAddress.locationName = humanReadableAddress;
      if (saveAsPickup == true) {
        Provider.of<AppInfo>(context, listen: false)
          .updateCustomerCurrentLocationAddress(userPickUpAddress);
      } else {
        Provider.of<AppInfo>(context, listen: false)
            .updateCustomerCurrentLocationAddress(userPickUpAddress);
      }
    } else {
      searchAddressForGeographicCoOrdinates(position, context, saveAsPickup);
    }
    return humanReadableAddress;
  }

  static Future<String> mapLocationUsingFromLatLng(
      double lat, double lng, context) async {
    String humanReadableAddress = "", placeId = "", postalCode = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(apiUrl);

    if (response != "Error") {
      humanReadableAddress = response["results"][0]["formatted_address"];
      for (var component in response["results"][0]["address_components"]) {
        if (component["types"].contains("postal_code")) {
          postalCode = component["long_name"];
          break;
        }
      }
      print("postalCode::$postalCode");
      placeId = response["results"][0]["place_id"];
      // print("Map Location Result ::$placeId");
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = lat;
      userPickUpAddress.locationLongitude = lng;
      userPickUpAddress.locationId = placeId;
      userPickUpAddress.pinCode = postalCode;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<String> mapDropLocationUsingFromLatLng(
      double lat, double lng, context) async {
    String humanReadableAddress = "", placeId = "", postalCode = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(apiUrl);

    if (response != "Error") {
      humanReadableAddress = response["results"][0]["formatted_address"];
      for (var component in response["results"][0]["address_components"]) {
        if (component["types"].contains("postal_code")) {
          postalCode = component["long_name"];
          break;
        }
      }
      placeId = response["results"][0]["place_id"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = lat;
      userPickUpAddress.locationLongitude = lng;
      userPickUpAddress.locationId = placeId;
      userPickUpAddress.pinCode = postalCode;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOfLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static saveSenderContactDetails(
      String contactName, String contactNumber, context) async {
    final pref = await SharedPreferences.getInstance();
    if (contactName.isNotEmpty && contactNumber.isNotEmpty) {
      ContactModel senderContactDetails = ContactModel();
      senderContactDetails.contactName = contactName;
      senderContactDetails.contactNumber = contactNumber;

      pref.setString("sender_name", contactName);
      pref.setString("sender_number", contactNumber);
      Provider.of<AppInfo>(context, listen: false)
          .updateSenderContactDetails(senderContactDetails);
    } else {
      pref.setString("sender_name", "");
      pref.setString("sender_number", "");
    }
  }

  static saveReceiverContactDetails(
      String contactName, String contactNumber, context) async {
    if (contactName.isNotEmpty && contactNumber.isNotEmpty) {
      ContactModel receiverContactDetails = ContactModel();
      receiverContactDetails.contactName = contactName;
      receiverContactDetails.contactNumber = contactNumber;
      final pref = await SharedPreferences.getInstance();
      pref.setString("receiver_name", contactName);
      pref.setString("receiver_number", contactNumber);
      Provider.of<AppInfo>(context, listen: false)
          .updateReceiverContactDetails(receiverContactDetails);
    }
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng orginPosition, LatLng destinationPosition) async {
    //https://developers.google.com/maps/documentation/directions/start
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${orginPosition.latitude},${orginPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var response = await RequestAssistant.receiveRequest(url);
    if (response == "Error") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        response["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distance_text =
        response["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        response["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        response["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        response["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static saveBookingDetails(
      int? driverID,
      int? vehicleID,
      String vehicleImage,
      String vehicleName,
      String vehicleWeight,
      String estimatedTotalTime,
      double estimatedTotalDistance,
      double totalPrice,
      double basePrice,
      context) {
    if (vehicleID != null) {
      ActiveBookingModel bookingDetails = ActiveBookingModel();
      bookingDetails.driverID = driverID;
      bookingDetails.vehicleID = vehicleID;
      bookingDetails.vehicleImage = vehicleImage;
      bookingDetails.vehicleName = vehicleName;
      bookingDetails.vehicleWeight = vehicleWeight;
      bookingDetails.estimatedTotalTime = estimatedTotalTime;
      bookingDetails.estimatedTotalDistance = estimatedTotalDistance;
      bookingDetails.totalPrice = totalPrice;
      bookingDetails.basePrice = basePrice;

      Provider.of<AppInfo>(context, listen: false)
          .updateBookingDetails(bookingDetails);
    }
  }

  static saveGoodsTypeDetails(int? goodsTypeID, String goodsTypeName, context) {
    if (goodsTypeID != null) {
      GoodsTypesModel goodsTypeDetails = GoodsTypesModel();
      goodsTypeDetails.goodsTypeID = goodsTypeID;
      goodsTypeDetails.goodsTypeName = goodsTypeName;

      Provider.of<AppInfo>(context, listen: false)
          .updateGoodsTypeDetails(goodsTypeDetails);
    }
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    //Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates() {
    streamSubscriptionPosition!.resume();
    // Geofire.setLocation(
    //     currentFirebaseUser!.uid,
    //     driverCurrentPosition!.latitude,
    //     driverCurrentPosition!.longitude
    // );
  }


}
