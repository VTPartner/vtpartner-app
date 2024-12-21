import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vt_partner/apps/cab_customer_app/pages/bookingReview/cab_pickup_to_drop_location_confirm.dart';
import 'package:vt_partner/apps/cab_customer_app/pages/dropLocation/cab_drop_location_search.dart';
import 'package:vt_partner/apps/cab_customer_app/pages/dropLocation/cab_map_drop_location.dart';
import 'package:vt_partner/apps/cab_customer_app/pages/pickupLocation/cab_map_pickup_location.dart';
import 'package:vt_partner/apps/cab_customer_app/pages/pickupLocation/cab_pickup_location_search.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/agent_documents_scanner/aadhar_card_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/agent_documents_scanner/agent_selfie_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/agent_documents_scanner/driving_license_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/agent_documents_scanner/pan_card_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/cab_agent_document_verification.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/cab_agent_owner_details.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/cab_agent_vehicle_document_verification.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/owner_documents/owner_photo_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/vehicle_documents/vehicle_image_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/vehicle_documents/vehicle_insurance_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/vehicle_documents/vehicle_noc_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/vehicle_documents/vehicle_plate_no_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/vehicle_documents/vehicle_puc_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/documents/vehicle_documents/vehicle_rc_upload.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/login.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/register.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/auth/verification.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/contactUs/contact_us.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/editProfile/edit_profile.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/faqs/faqs.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/home/home.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/inviteFriends/invite_friends.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/rating/my_rating.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/rechargeHistory/recharge_history.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/recharges/recharge_home_screen.dart';
import 'package:vt_partner/apps/cab_driver_app/pages/rides/my_rides.dart';
import 'package:vt_partner/apps/customer_app/pages/auth/login.dart';
import 'package:vt_partner/apps/customer_app/pages/auth/register.dart';
import 'package:vt_partner/apps/customer_app/pages/auth/verification.dart';
import 'package:vt_partner/apps/customer_app/pages/cancelBooking/cancel_booking.dart';
import 'package:vt_partner/apps/customer_app/pages/home/home.dart';
import 'package:vt_partner/apps/customer_app/pages/onboardings/onboarding.dart';
import 'package:vt_partner/apps/customer_app/pages/rating/rating.dart';
import 'package:vt_partner/apps/drivers_agent_app/pages/auth/login.dart';
import 'package:vt_partner/apps/drivers_agent_app/pages/auth/register.dart';
import 'package:vt_partner/apps/drivers_agent_app/pages/auth/verification.dart';
import 'package:vt_partner/apps/drivers_app/pages/bookingReview/driver_pickup_to_drop_screen.dart';
import 'package:vt_partner/apps/drivers_app/pages/dropLocation/drivers_drop_location_search.dart';
import 'package:vt_partner/apps/drivers_app/pages/dropLocation/drivers_map_drop_location.dart';
import 'package:vt_partner/apps/drivers_app/pages/pickupLocation/driver_map_pickup_location.dart';
import 'package:vt_partner/apps/drivers_app/pages/pickupLocation/driver_pickup_location_search.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/auth/login.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/auth/verification.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/contactUs/contact_us.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/earningsHistory/earnings_history.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/editProfile/edit_profile.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/faqs/faqs.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/home/home.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/inviteFriends/invite_friends.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/newRide/new_ride_details.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/notification/notification.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/rating/my_rating.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/rechargeHistory/recharge_history.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/recharges/recharge_home_screen.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/rideDetail/ride_detail.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/rides/my_rides.dart';
import 'package:vt_partner/apps/goods_driver_app/pages/wallet/wallet.dart';
import 'package:vt_partner/apps/handy_man_app/pages/allHandyManServices/all_handy_man_services.dart';
import 'package:vt_partner/apps/handy_man_app/pages/allHandyManSubServices/handy_man_all_sub_services.dart';
import 'package:vt_partner/apps/handy_man_app/pages/workLocation/handy_man_work_location_search.dart';
import 'package:vt_partner/apps/handy_man_app/pages/workLocation/handy_man_work_map_location.dart';
import 'package:vt_partner/apps/jcb_crane_app/pages/workLocation/work_location_screen.dart';
import 'package:vt_partner/apps/jcb_crane_app/pages/workLocation/work_map_location_confirm.dart';


import 'package:vt_partner/customer_pages/screens/authentication/customer_login.dart';
import 'package:vt_partner/customer_pages/screens/authentication/customer_otp_verification_screen.dart';
import 'package:vt_partner/customer_pages/screens/authentication/new_customer_details_screen.dart';
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
import 'package:vt_partner/customer_pages/screens/main_screens/tab_pages/home_screen_tab.dart';
import 'package:vt_partner/customer_pages/screens/onboardings/customer_onboarding_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/locate_on_map_screen.dart';
import 'package:vt_partner/customer_pages/screens/pickup_location/pickup_location_screen.dart';
import 'package:vt_partner/customer_pages/screens/ride_details/completed_ride_details_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_document_verification_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_login_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_owner_details_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agent_vehicle_verification.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/agents_otp_verification.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/documents/aadhar_card_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/documents/driving_license_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/documents/owner_selfie_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/documents/pan_card_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/owner_documents/owner_photo_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/vehicle_documents/vehicle_image_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/vehicle_documents/vehicle_insurance_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/vehicle_documents/vehicle_noc_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/vehicle_documents/vehicle_plate_no_upload.dart';

import 'package:vt_partner/delivery_agent_pages/screens/authentication/vehicle_documents/vehicle_puc_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/authentication/vehicle_documents/vehicle_rc_upload.dart';
import 'package:vt_partner/delivery_agent_pages/screens/home/agent_home_screen.dart';
import 'package:vt_partner/delivery_agent_pages/screens/settings/agent_settings_screen.dart';

import 'package:vt_partner/splash_screen.dart';

import '../customer_pages/screens/main_screens/customer_main_screen.dart';
import '../customer_pages/screens/ride_details/ongoing_ride_details_screen.dart';
import 'route_names.dart';
import '../delivery_agent_pages/screens/new_trip_screen/new_trip_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  // print('generateRoute: ${settings.name}');
  switch (settings.name) {
    case OnBoardingRoute:
      return _getPageRoute(const OnboardingScreen());
    // return _getPageRoute(const CustomerOnBoardingScreen());
    case CustomerLoginRoute:
      return _getPageRoute(const LoginScreen());
    // return _getPageRoute(const CustomerLoginScreen());
    case NewCustomerDetailsRoute:
      return _getPageRoute(const RegisterScreen());
    // return _getPageRoute(const NewCustomerDetailsScreen());
    case CustomerOTPVerificationRoute:
      return _getPageRoute(const VerificationScreen());
    // return _getPageRoute(const CustomerOTPVerificationScreen());
    case CustomerMainScreenRoute:
      return _getPageRoute(const HomeScreen());
    // return _getPageRoute(const CustomerMainScreen());
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
    case GoodsDriverRatingScreenRoute:
      return _getPageRoute(const RatingScreen());
    case CancelBookingRoute:
      return _getPageRoute(const CancelBookingScreen());

//Agent Routes

    case AgentLoginRoute:
      return _getPageRoute(const GoodsDriverLoginScreen());
    // return _getPageRoute(const AgentLoginScreen());
    case AgentOTPRoute:
      return _getPageRoute(const GoodsDriverVerificationScreen());
    // return _getPageRoute(const AgentOtpVerificationScreen());
    case AgentDocumentVerificationRoute:
      return _getPageRoute(const AgentDocumentVerificationScreen());
    case AgentVehicleDocumentVerificationRoute:
      return _getPageRoute(const AgentVehicleDocumentVerification());
    case AgentOwnerDetailsRoute:
      return _getPageRoute(const VehicleOwnerDetailsScreen());
    case AgentHomeScreenRoute:
      return _getPageRoute(const GoodsDriverHomeScreen());
    // return _getPageRoute(const AgentHomeScreen());
    case AgentSettingsRoute:
      return _getPageRoute(const AgentSettingsScreen());
    case AadharCardUploadRoute:
      return _getPageRoute(const AadharCardUploadScreen());
    case PanCardUploadRoute:
      return _getPageRoute(const PanCardUploadScreen());
    case DrivingLicenseUploadRoute:
      return _getPageRoute(const DrivingLicenseUploadScreen());
    case OwnerSelfieUploadRoute:
      return _getPageRoute(const OwnerSelfieUpload());
    case NewTripDetailsRoute:
      return _getPageRoute(const GoodsRiderNewRideDetails());
    // return _getPageRoute(NewTripScreen());
    //Vehicle Documents upload
    case VehicleImagesUploadRoute:
      return _getPageRoute(const VehicleImageUpload());
    case VehiclePlateImagesUploadRoute:
      return _getPageRoute(const VehiclePlateNoUpload());
    case RCUploadRoute:
      return _getPageRoute(const VehicleRCUpload());
    case InsuranceUploadRoute:
      return _getPageRoute(const VehicleInsuranceUpload());
    case NOCUploadRoute:
      return _getPageRoute(const VehicleNOCUpload());
    case PUCUploadRoute:
      return _getPageRoute(const VehiclePUCUpload());
    case OwnerPhotoUploadRoute:
      return _getPageRoute(const OwnerPhotoUpload());

    //Settings Screens
    case GoodsDriverEditProfileRoute:
      return _getPageRoute(const GoodsDriverEditProfileScreen());
    case GoodsDriverRidesRoute:
      return _getPageRoute(const GoodsDriverRideScreen());
    case GoodsDriverRideDetailsRoute:
      return _getPageRoute(const GoodsDriverRideDetailScreen());
    case GoodsDriverEarningsRoute:
      return _getPageRoute(const GoodsDriverEarningHistory());
    case GoodsDriverRatingsRoute:
      return _getPageRoute(const GoodsDriverRatingScreen());
    case GoodsDriverRechargeHomeRoute:
      return _getPageRoute(const GoodsDriverRechargeHomeScreen());
    case GoodsDriverRechargeHistoryRoute:
      return _getPageRoute(const GoodsDriverRechargeHistoryScreen());
    case GoodsDriverWalletRoute:
      return _getPageRoute(const GoodsDriverWalletScreen());
    case GoodsDriverNotificationRoute:
      return _getPageRoute(const GoodsDriverNotificationScreen());
    case GoodsDriverInviteFriendsRoute:
      return _getPageRoute(const GoodsDriverInviteFriendsScreen());
    case GoodsDriverFAQSRoute:
      return _getPageRoute(const GoodsDriverFAQsScreen());
    case GoodsDriverContactUsRoute:
      return _getPageRoute(const GoodsDriverContactUsScreen());



//Cab Customer Pages
    case CabHomeRoute:
      return _getPageRoute(const CabHomeScreen());
    case CabPickupLocationSearchRoute:
      return _getPageRoute(const CabPickupLocationSearch());
    case CabLocateOnMapPickupLocationRoute:
      return _getPageRoute(const CabMapPickupLocation());
    case CabDestinationLocationSearchRoute:
      return _getPageRoute(const CabDropLocationSearch());
    case CabLocateOnMapDestinationLocationRoute:
      return _getPageRoute(const CabMapDropLocation());
    case CabLocationsConfirmRoute:
      return _getPageRoute(const CabPickupToDropLocationConfirmScreen());
    case CabSearchingForCabRoute:
      return _getPageRoute(const SearchingCabDriverScreen());
    case CabBookingConfirmedRoute:
      return _getPageRoute(const CabBookingConfirmedScreen());
    
//Driver Customer Pages
    case DriversAppPickupLocationSearchRoute:
      return _getPageRoute(const DriverPickupLocationSearchScreen());
    case DriversAppPickupLocationMapRoute:
      return _getPageRoute(const DriverMapPickupLocationScreen());
    case DriversAppDropLocationSearchRoute:
      return _getPageRoute(const DriversDropLocationScreen());
    case DriversAppDropLocationMapRoute:
      return _getPageRoute(const DriversMapDropLocationScreen());
    case DriversAppPickToDropRoute:
      return _getPageRoute(const DriverPickupToDropLocationsScreen());

    //JCB & Crane Customer Pages
    case JcbCraneAppWorkLocationSearchRoute:
      return _getPageRoute(const JcbWorkLocationSearchScreen());
    case JcbCraneAppWorkLocationMapRoute:
      return _getPageRoute(const JcbWorkMapLocationScreen());

    //HandyMan Customer Pages
    case HandyManAppAllServicesRoute:
      return _getPageRoute(const AllHandyManServicesScreen());
    case HandyManAppAllSubServicesRoute:
      return _getPageRoute(const HandyManAllSubServicesScreen());
    case HandyManAppWorkLocationSearchRoute:
      return _getPageRoute(const HandyManWorkLocationSearchScreen());
    case HandyManAppWorkLocationMapRoute:
      return _getPageRoute(const HandyManWorkMapLocationScreen());

    //Cab Agent Pages
    case CabAgentLoginRoute:
      return _getPageRoute(const CabDriversLoginScreen());
    case CabAgentOtpRoute:
      return _getPageRoute(const CabDriverOtpVerificationScreen());
    case CabAgentRegistrationRoute:
      return _getPageRoute(const CabDriverRegistrationScreen());
    case CabAgentDrivingLicenseUploadRoute:
      return _getPageRoute(const CabAgentDrivingLicenseUploadScreen());
    case CabAgentAadharCardUploadRoute:
      return _getPageRoute(const CabAgentAadharCardUploadScreen());
    case CabAgentPanCardUploadRoute:
      return _getPageRoute(const CabAgentPanCardUploadScreen());
    case CabAgentSelfieUploadRoute:
      return _getPageRoute(const CabAgentSelfieUpload());
    case CabAgentOwnerDetailsRoute:
      return _getPageRoute(const CabAgentVehicleOwnerDetailsScreen());
    case CabAgentDocumentDetailsUploadRoute:
      return _getPageRoute(const CabAgentDocumentVerificationScreen());
    case CabAgentVehicleDocumentDetailsUploadRoute:
      return _getPageRoute(
          const CabAgentVehicleDocumentationVerificationScreen());
    case CabAgentOwnerPhotoUploadRoute:
      return _getPageRoute(const CabAgentOwnerPhotoUpload());
    case CabAgentVehicleImagesUploadRoute:
      return _getPageRoute(const CabAgentVehicleImageUpload());
    case CabAgentVehiclePlateImagesUploadRoute:
      return _getPageRoute(const CabAgentVehiclePlateNoUpload());
    case CabAgentRCUploadRoute:
      return _getPageRoute(const CabAgentVehicleRCUpload());
    case CabAgentInsuranceUploadRoute:
      return _getPageRoute(const CabAgentVehicleInsuranceUpload());
    case CabAgentNOCUploadRoute:
      return _getPageRoute(const CabAgentVehicleNOCUpload());
    case CabAgentPUCUploadRoute:
      return _getPageRoute(const CabAgentVehiclePUCUpload());
    case CabAgentHomeRoute:
      return _getPageRoute(const CabDriversHomeScreen());
    case CabAgentEditProfileRoute:
      return _getPageRoute(const CabDriverEditProfileScreen());
    case CabAgentMyRidesRoute:
      return _getPageRoute(const CabDriverRideScreen());
    case CabAgentMyRatingsRoute:
      return _getPageRoute(const CabDriverRatingScreen());
    case CabAgentRechargeHomeRoute:
      return _getPageRoute(const CabDriverRechargeHomeScreen());
    case CabAgentRechargeHistoryRoute:
      return _getPageRoute(const CabDriverRechargeHistoryScreen());
    case CabAgentInviteFriendsRoute:
      return _getPageRoute(const CabDriverInviteFriendsScreen());
    case CabAgentFAQsRoute:
      return _getPageRoute(const CabDriverFAQsScreen());
    case CabAgentContactUsRoute:
      return _getPageRoute(const CabDriverContactUsScreen());

    //Driver Agent Routes/ Pages
    case DriverAgentLoginRoute:
      return _getPageRoute(const DriverAgentLoginScreen());
    case DriverAgentOtpRoute:
      return _getPageRoute(const DriverAgentOtpVerificationScreen());
    case DriverAgentRegistrationRoute:
      return _getPageRoute(const DriverAgentRegistrationScreen());
    


    default:
      return _getPageRoute(const MySplashScreen());
  }
}

PageRoute _getPageRoute(Widget child) {
  // return PageTransition(
  //   child: child,
  //   type: PageTransitionType.rightToLeft,
  // );
  return CupertinoPageRoute(builder: (context) => child);
}
