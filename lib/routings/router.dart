import 'package:flutter/cupertino.dart';


import 'package:vt_partner/customer_pages/screens/authentication/customer_login.dart';
import 'package:vt_partner/customer_pages/screens/authentication/customer_otp_verification_screen.dart';
import 'package:vt_partner/customer_pages/screens/authentication/new_customer_details_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/add_stops_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/booking_locations_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/booking_review_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/booking_searching_driver_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/booking_success_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/coupons_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/goods_type_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/pickup_to_drop_map_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/service_type_screen.dart';
import 'package:vt_partner/customer_pages/screens/booking_screens/vehicles_available_screen.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/booking_screens/booking_confirmed_screen.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/booking_screens/confirm_locations_screen.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/booking_screens/searching_cab_driver_screen.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/cab_home_screen.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/destination_screens/location_on_map_destination.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/destination_screens/search_destination_screen.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/pickup_screens/location_on_map_pickup.dart';
import 'package:vt_partner/customer_pages/screens/cab_booking_screens/pickup_screens/search_pickup_screen.dart';
import 'package:vt_partner/customer_pages/screens/contacts_screens/reciever_contact_screen.dart';
import 'package:vt_partner/customer_pages/screens/contacts_screens/sender_contact_screen.dart';
import 'package:vt_partner/customer_pages/screens/drop_location/drop_location_locate_on_map.dart';
import 'package:vt_partner/customer_pages/screens/onboardings/customer_onboarding_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/locate_on_map_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/pickup_location_screen.dart';
import 'package:vt_partner/customer_pages/screens/ride_details/completed_ride_details_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_document_verification_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_login_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_vehicle_verification.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agents_otp_verification.dart';
import 'package:vt_partner/delivery_agent_pages/screens/home/agent_home_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/settings/agent_settings_screen.dart';

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
    // case AddStopsRoute:
    //   return _getPageRoute(const AddStopsScreen());
    case PickToDropPolyLineMapRoute:
      return _getPageRoute(const PickToDropPolyLineMapScreen());
    case SelectVehiclesRoute:
      return _getPageRoute(const VehiclesAvailableScreen());
    case BookingReviewDetailsRoute:
      return _getPageRoute(const BookingReviewScreen());
    case ReceiverContactRoute:
      return _getPageRoute(const ReceiverContactScreen());
    case SenderContactRoute:
      return _getPageRoute(const SenderContactScreen());
    case GoodsTypeRoute:
      return _getPageRoute(const GoodsTypeScreen());
    case CouponsRoute:
      return _getPageRoute(const CouponsScreen());
    case BookingSearchDriverRoute:
      return _getPageRoute(const BookingSearchDriverScreen());
    case BookingSuccessScreenRoute:
      return _getPageRoute(const BookingSuccessScreen());

//Agent Routes

    case AgentLoginRoute:
      return _getPageRoute(const AgentLoginScreen());
    case AgentOTPRoute:
      return _getPageRoute(const AgentOtpVerificationScreen());
    case AgentDocumentVerificationRoute:
      return _getPageRoute(const AgentDocumentVerificationScreen());
    case AgentVehicleDocumentVerificationRoute:
      return _getPageRoute(const AgentVehicleDocumentVerification());
    case AgentHomeScreenRoute:
      return _getPageRoute(const AgentHomeScreen());
    case AgentHomeScreenRoute:
      return _getPageRoute(const AgentHomeScreen());
    case AgentSettingsRoute:
      return _getPageRoute(const AgentSettingsScreen());


//Cab Customer Pages
    case CabHomeRoute:
      return _getPageRoute(const CabHomeScreen());
    case CabPickupLocationSearchRoute:
      return _getPageRoute(const CabUserSearchPickupLocationScreen());
    case CabLocateOnMapPickupLocationRoute:
      return _getPageRoute(const CabUserPickupLocateOnMapScreen());
    case CabDestinationLocationSearchRoute:
      return _getPageRoute(const CabUserSearchDestinationLocationScreen());
    case CabLocateOnMapDestinationLocationRoute:
      return _getPageRoute(const CabUserLocationOnMapDestinationScreen());
    case CabLocationsConfirmRoute:
      return _getPageRoute(const CabConfirmLocationsScreen());
    case CabSearchingForCabRoute:
      return _getPageRoute(const SearchingCabDriverScreen());
    case CabBookingConfirmedRoute:
      return _getPageRoute(const CabBookingConfirmedScreen());
    

    default:
      return _getPageRoute(const MySplashScreen());
  }
}

PageRoute _getPageRoute(Widget child) {
  return CupertinoPageRoute(builder: (context) => child);
}
