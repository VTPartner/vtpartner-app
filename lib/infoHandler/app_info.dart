import 'package:flutter/cupertino.dart';
import 'package:vt_partner/models/contact_model.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/models/pickup_location_map_direction.dart';

class AppInfo extends ChangeNotifier {
  Directions? userCurrentLocation;
  Directions? userPickupLocation;
  Directions? userDropOfLocation;
  ContactModel? senderContactDetail;
  ContactModel? receiverContactDetail;
  // PickUpLocationOnMap? pickUpLocationOnMap;

  void updateCustomerCurrentLocationAddress(Directions userCurrentAddress) {
    userCurrentLocation = userCurrentAddress;
    notifyListeners();
  }

  void updatePickupLocationAddress(Directions userPickupAddress) {
    userPickupLocation = userPickupAddress;
    notifyListeners();
  }

  // void updatePickupLocationOnMap(PickUpLocationOnMap mapPickupAddress) {
  //   pickUpLocationOnMap = mapPickupAddress;
  //   notifyListeners();
  // }

  void updateDropOfLocationAddress(Directions? userDropOfAddress) {
    userDropOfLocation = userDropOfAddress;
    notifyListeners();
  }

  void updateSenderContactDetails(ContactModel? contactModel) {
    senderContactDetail = contactModel;
    notifyListeners();
  }

  void updateReceiverContactDetails(ContactModel? contactModel) {
    receiverContactDetail = contactModel;
    notifyListeners();
  }
}
