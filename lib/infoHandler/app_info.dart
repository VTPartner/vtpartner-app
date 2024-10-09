import 'package:flutter/cupertino.dart';
import 'package:vt_partner/models/contact_model.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/models/pickup_location_map_direction.dart';
import 'package:vt_partner/models/stops.dart';

class AppInfo extends ChangeNotifier {
  Directions? userCurrentLocation;
  Directions? userPickupLocation;
  Directions? userDropOfLocation;
  ContactModel? senderContactDetail;
  ContactModel? receiverContactDetail;
  List<Stop>? userStopsList;


  List<Directions> _destinations = [];

  List<Directions> get destinations => _destinations;
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

  void updateStopsList(List<Stop>? stops) {
    userStopsList = stops;
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


  void addDestination(Directions destination) {
    if (_destinations.length < 3) {
      _destinations.add(destination);
      notifyListeners();
    }
  }

  void updateDestination(int index, Directions newDestination) {
    if (index >= 0 && index < _destinations.length) {
      _destinations[index] = newDestination;
      notifyListeners();
    }
  }

  void removeDestination(int index) {
    if (index >= 0 && index < _destinations.length) {
      _destinations.removeAt(index);
      notifyListeners();
    }
  }
}
