import 'package:flutter/cupertino.dart';


import 'package:vt_partner/customer_pages/screens/authentication/customer_login.dart';
import 'package:vt_partner/customer_pages/screens/authentication/customer_otp_verification_screen.dart';
import 'package:vt_partner/customer_pages/screens/authentication/new_customer_details_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/booking_locations_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/booking_review_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/service_type_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/vehicles_available_screen.dart';
import 'package:vt_partner/customer_pages/screens/contacts_screens/reciever_contact_screen.dart';
import 'package:vt_partner/customer_pages/screens/contacts_screens/sender_contact_screen.dart';
import 'package:vt_partner/customer_pages/screens/drop_location/drop_location_locate_on_map.dart';
import 'package:vt_partner/customer_pages/screens/onboardings/customer_onboarding_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/locate_on_map_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/pickup_location_screen.dart';
import 'package:vt_partner/customer_pages/screens/ride_details/completed_ride_details_screen.dart';

import 'package:vt_partner/splash_screen.dart';

import '../customer_pages/screens/main_screens/customer_main_screen.dart';
import '../customer_pages/screens/ride_details/ongoing_ride_details_screen.dart';
import 'route_names.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  // print('generateRoute: ${settings.name}');
  switch (settings.name) {
    case OnBoardingRoute:
      return _getPageRoute(const CustomerOnBoardingScreen());
    case CustomerLoginRoute:
      return _getPageRoute(const CustomerLoginScreen());
    case NewCustomerDetailsRoute:
      return _getPageRoute(const NewCustomerDetailsScreen());
    case CustomerOTPVerificationRoute:
      return _getPageRoute(const CustomerOTPVerificationScreen());
    case CustomerMainScreenRoute:
      return _getPageRoute(const CustomerMainScreen());
    case CustomerOngoingRideDetailsRoute:
      return _getPageRoute(const CustomerOngoingRideDetailsScreen());
    case CustomerCompletedRideDetailsRoute:
      return _getPageRoute(const CustomerCompletedRideDetailsScreen());


    case PickUpAddressRoute:
      return _getPageRoute(const PickupLocationScreen());
    case LocateOnMapPickupLocationRoute:
      return _getPageRoute(const LocateOnMapPickupLocation());
    case DropLocateOnMapRoute:
      return _getPageRoute(const DropLocationLocateOnMap());

    //Goods Booking Sequence
    case ServiceTypesRoute:
      return _getPageRoute(const ServiceTypeScreen());
    case PickUpAndDropBookingLocationsRoute:
      return _getPageRoute(const BookingLocationsScreen());
    case SelectVehiclesRoute:
      return _getPageRoute(const VehiclesAvailableScreen());
    case BookingReviewDetailsRoute:
      return _getPageRoute(const BookingReviewScreen());
    case ReceiverContactRoute:
      return _getPageRoute(const ReceiverContactScreen());
    case SenderContactRoute:
      return _getPageRoute(const SenderContactScreen());

    default:
      return _getPageRoute(const MySplashScreen());
  }
}

PageRoute _getPageRoute(Widget child) {
  return CupertinoPageRoute(builder: (context) => child);
}
