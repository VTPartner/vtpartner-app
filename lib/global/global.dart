library global;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vt_partner/themes/themes.dart';
import 'package:vt_partner/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:intl/intl.dart';

// Name:Vt Partner Notification Services
// Name:Apple Notification Service
// Key ID:5G44D9K8P9
// Services:Apple Push Notifications service (APNs)

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
Position? driverCurrentPosition;
var devMode = 1; // Change this to 1 for development mode
late String serverEndPoint;
late String serverEndPointImage;

void initializeEndpoints() {
  if (devMode == 1) {
    serverEndPoint = "http://77.37.47.156:8000/api/vt_partner";
    serverEndPointImage = "http://77.37.47.156:8000/api/vt_partner";
  } else {
    serverEndPoint = "https://www.vtpartner.org/api/vt_partner";
    serverEndPointImage = "https://www.vtpartner.org/api/vt_partner";
  }
}

String razorpay_key =
    "rzp_test_crEnVFpHxMh7sZ"; //Test key rzp_test_crEnVFpHxMh7sZ

final serviceAccountFirebaseJson = {
  "type": "service_account",
  "project_id": "vt-partner-4a2b1",
  "private_key_id": "dc68810612137371501477515a27fb68382ec393",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCT4vZRt8HHq69e\niISlL9VrRf9vyzHBTytEHp0luIPM/w0O7/Gs1nzoZqf3jiKh7AwCjBuvrIYV9+xn\nC50LcTmJk25B6vFGP4qRmzWuC3VamsAss1QB1rtZU63fmXJjvByfyc+q4xtmPz20\nbd/zIZ0dHw6AehfAZada6SknT7n/YpbO59adcKbc8UOeCJSb38gAAHITvxKrQp+E\nNTKyfi2M0tEGMPrnNuda+5yR9yyAIg6xq17bTybPhz2P+TyvBPpZykNCWwo1Hucg\ntJvfbFtkb239R7bNbb8Juh2FB0qhflZ8aFQHKMN1VWgPBDnOmQtcOXyplRL/v9BY\nKammJM95AgMBAAECggEADS13bPMuk3v3KbmI9k4zmnY3i27j/VlwXcbLknmlVu4w\nK/FSC+hl43CITY0PBXYq4Mw6yFXbcdgwasM0aHlbmuh19e45Nx0A3DYkG6DeQWdS\nMfl9xhcsBQrpjqfV81CnDU72j//iKGOAvFPhFYFchmSGzohyltyIA9gMaHoYdQrh\nf2DLDRmiD0yypq75XM3ddVj3Fx08Omb3iXMmeVjdryzO55Ze1fL3tkDmX2fOc8Qm\nPlJyrtFXojA7W1VjqmvJWZmz4sr5EmXeqqkBok7e0XV3d/kTTucLjjT32kL9jv8e\nxjTPN8bnvBHE7m7iNQ/w5P7TJFC9up/Xciy/d5BDHQKBgQDEU51Ok1wXw7KyHVvC\nkYa7BcF/kQ+Or7X2UEf2J8zl9q9cH8woFROVI/AyaQV8PAcODjlCd7/ZwsnK3l0H\nZ5PTAr0JMBlV3+kM45pz4acwzBCwhJvvUkF5dyqwQMBANJc+V82XgqPuvvlzzM5p\nhdX0z+7Vqgmeh37/790tFdogRQKBgQDA1izpTCsQAXZU8kN0fW7nM8OXYTv6UN7e\nsC/UODgiIvHiR3LufX8TsWxKPmqnQ+SOT8BniWEkaTtpv4HAke9ZlTBilpu1bzgx\n6Y/vRhGoQ0p6uz9NTpi9D/0/gyAcJbPpwnLY/H8nSAfwhgjwlXie++oHSsZnSqBP\nnLV+Og2npQKBgQCTsrPtoT7vQfL1vNCDmCfcG4BvEBq8JcSnAc6hiV/Ewck7bVCR\n9wk8ckUKJ6hQxngoQtsg/iX/FWPqk085etrjLHQ6rUziJgmWAMT52RGGzH7hzWHi\nsedAEj6zSoNXyjjeVf/9s/LQciwIylOfX2iPPL9ZTwrdkOIiebnTaVUoYQKBgCuN\ntCMVMvywd9uDxDyBQBU0Gc8NBRDqRwwg2wyhjfwXzG4BGTJIYfU+s2ipZElXCj4i\nQSChZLFmmyatPE8UJu0ixwTdY1m9PwH28K1oNAC/AglqVUfOoqzA+b/oi84Prez0\nICBmFwn2OOTYQRilidLOrvLqrpkRv9d7W3qg/giJAoGAHRRs6E+vJZAa2zOedLxj\nLM2UubmLDofHfMir0URqXBIZmeToHkTTgyzuZRozt5YGB7Ul0aveLrUOoge0fd4j\n73r18VnILILi5QNSz5W4KHLGZtHCckhw90AnCIW9HMGW/0j2oyrUNykdbrXMwXZw\nd3u/d0DBTismeit1ev/4ftg=\n-----END PRIVATE KEY-----\n",
  "client_email":
      "firebase-adminsdk-cxenn@vt-partner-4a2b1.iam.gserviceaccount.com",
  "client_id": "106177785472692197323",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-cxenn%40vt-partner-4a2b1.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};



// final serviceAccountJson = {
//   "type": "service_account",
//   "project_id": "vt-partner-4a2b1",
//   "private_key_id": "6fd4f1ca330d149f862a2d54488c027a507152f8",
//   "private_key":
//       "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCIeONh/TNbWuyc\nmLKOakj0YmGaXr6MtyToZHV/eP2um9X8IAMLSXksJyh1vTOgsl6L568wMQzfLjTh\ngqqVjIDcyDFOvVQVQspYAhUc5UGJrW2+c9S0kpcT5k5ek5i1rl+3kG6P6LMWb7+8\n93ClkmjMswNAwyXuxlELWl72qGkhzG/BtoSdB7qurDdb5zIr1DHAf4wkvQ8FZ58p\n+aX/iDwt94+efRGKNRqDCysZozu+y4bS65302+W8J1pgff+V/ma04BxqzUAPSwGq\n0r/ti6aqByW/uDgh7FrvpQyTjww2ul3zrsg0y+LLXHP5GsgWXIPP242rFdIOhH1Q\n4bWQFp6tAgMBAAECggEAAJdlhNswCclPFS6kN3HGdyil+6FFeh6hDlDBIZhIoSUT\nvE/3M2lSGRriVgBH5P5g4oJShAbyY1Uz7XY/fv5o4IwNiqXPY3gyoEcCCGoF6q7R\ntu2RkmbAONnapRZGpyLmT0lU8VK00/gQAKWh21XTFnAAJ5uw4mQBneb6Wl9IdVkH\n1CCWvtaky9F89uetqO4Vi314mGxk0jUkXPJXsKlB0phLYzFQsHaduC2q7cqO+qdq\ndHbztKrdiQCaH4vTUUPKpamwR9ai0lRYGHzPmYa032mwTGeFmrvmztrODaxwQan2\ngRYiovznBCavVCMTnrPgwct1gBQSSW+6qv3AsZWSEQKBgQC/MsO+jS3ww616a2Z0\nsr9qyuNF8zonUaEX13NOx3hBmlvB/Jzu17MV5m37qYhAtssVdEMfe1/YZQGcK03d\ny1Y/W7pmN1SLfYtwG5bgNP4aTmSenivHwk0XrAAcwT1Gy9IdlO3nKpxFA1WW+MVB\nLA1+XpSPNv/TCjBlZACFjHQH/wKBgQC2udbx2IOVOEKKGzDoMTL/OwEno//6/blk\n/SgFL/9RPsVIr6ooTi0e8BiU4iUaY5bhQIt+0U7Mjuk8RXWp0qvWtpdXE/9SWM9p\nJdpxcfeODZuTqrmAXkO7XwkTclOjEl8V9Z0SgZZfiTKZjmQrK6mmMC5j1AVxCbj1\nBb1qTU/5UwKBgCTmPzC/PmaA3TILGDLdbGPH1CTj1A1Si6x2QCKsDGFc0OiXQBI4\nPq+zUPaIuWsD3B2/2lRxEwZIOA9TrCtp2rNPmKGxe/ePuyFfsbaDg6bAClsyW3Cp\n5wbygvMJuDG5lEtxOpiqeI45HoOMb0Uso04IItOg4a5xAPYQXqlned0xAoGBAKiR\nWsyza/g99YyItx6NPLmeilsyfVTjuqOCs+fNNqGR4dhDThtuu0tePZ8j3QyyMR/O\nNqIgn6wwbtROU9T9587llUocxZ8HFRiwdgvQEot23D5m8kiNLbjuXGYXQzceHKAa\nfPP0nm+2Fvr4FEqLNi99JV6s2vRD/t/zkqE9f3jHAoGAbt272ErDz/13uiljtgUM\nFmijKG8vE4odUlZMLMy0FPJzk1xbI1EX0u7GehMTVO61u8Rxu9Zor6tB6W/kJlSX\n9Ikcl9vlnQKWWyGYW0zTp7V2xuOupdoHK70mzNvIyA1EWsoObd0GuwCF5ukht/c8\n2bYDvQuyMg51OxYM/PbuSw4=\n-----END PRIVATE KEY-----\n",
//   "client_email":
//       "vt-partner-app-latest@vt-partner-4a2b1.iam.gserviceaccount.com",
//   "client_id": "115233621954078923596",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url":
//       "https://www.googleapis.com/robot/v1/metadata/x509/vt-partner-app-latest%40vt-partner-4a2b1.iam.gserviceaccount.com",
//   "universe_domain": "googleapis.com"
// };

final serviceAccountJson = {
  "type": "service_account",
  "project_id": "vt-partner-8317b",
  "private_key_id": "7e68b260d70d30cd4c4b3fa0551d2b19dad6bcfa",
  "private_key":
      "-----BEGIN PRIVATE KEY-----\nMIIEugIBADANBgkqhkiG9w0BAQEFAASCBKQwggSgAgEAAoIBAQCzddBYQL8rUGT8\nP0R/+HftofhxNYQ2mA7JEen3GI5hHtt3Z1ErkLkA5q3Hv5ht6hv+B0IkXE2AadWP\n/CYZPxUCKLexMoom7tt3ykz2sRp7bfoea8YMEsY32qV3M6/q6bKb9gFKAT2V9cvx\ni7svuYrMrC0J40S52occpDWpnqQiIxjhhOA6Mb+Hvn59r5G4Ic81gbcSV/EXKRQ8\nrbY2x1OrsIX3J37yHcY5amlI1IqhE8qO0qQ3S6j7qJg59L3cI89HpsYYOdDp+3dv\nMxx12sp/whJ2Mo/EI8DaasYLCZDPXkvPC/fuboeMA5BESwcRCegwyBOKAucuAZwi\nK4hbWEiZAgMBAAECggEABZBEuAOz2YQpyU8t0LjTgPy5Pss9sNKYfL/PLM+oVFb4\nT1SW5d6b+aztHMjyERBFs2Omt4lcBrvhONBEnxo/TLyV60qpkUjs6WMObURy0XpI\nm4pUTroDRqaC5DXoQYRiuuaOxixRLDW9T5z5HeLm7G73C3wt/IQLlcX6eup15K/8\nB6b0z/4zIX9jezzfxyeXj0l5VeV/tnWNjlZZQvxcIj9QslI6htWPTG88NPUmE4jV\nKXU2qDAQYJCn8xXNePkJrCrJM3O0lqI3eQQ6gxQn8oQR3Rvtj4VehUS8zaOvFK2V\nNdff+aq8A7tpDilVY/ptZWbnBpH+lWjjR1G+BYlETQKBgQDoJvG6/Qkc+kuXvgN1\nb89uSxbVn2JmkIBWn6L4Giy8c6F/x2Cajq06TsJ5wx3Iq/oubJZBiqkN5k80Im8E\nqRQ+69mwEGPSM7gGMDwyY/eNBLW6VmgWEIxbgTIiDGDtEGpf8kehM1IsdPkqvZ/F\nmzeRUJfQxjyKeDCZo87EZxKy3QKBgQDF5TIpXy1YKAQ+pizxeHBGyTZa1atYUgVR\nLEjA55L78TjExouIryeTciILB2rWqUqJOom8HXi78/yPDxSBYNxDgSI/O+rHo4uo\nh8xq1ZtqwYLs2Cehfgziq19AH7w8gaoxrPB2KZ4c2bAtEbEz4EBaXLuwSyCnMCpy\nIoGDsNNa7QKBgEaqXBisH1MHyWzWNR1RPJX5G2lJS92mjLpRe30EEqwGkplfqkNB\nvO8rvDzuLKnB17S77vziZVVKzr8y4BJOGVCR4ECcrJX2kkSn+BrqnRb64QpodOSK\ngv7zk7wTgomG3qp4CF/ETHYl4Ramg/TVq5N7McsmHJWVwk1yNGVKbsGtAoGASlF8\nuRTJTqYYkf6OOlDkuXCvPQWpR43l+UoMOIW/KWa5zwxRMo+06Safqkyqztrc5xRY\nzZCz2sISQxeCt+PMVH2WgvDZhwfgVvZIyoZVy43IwXGb0IYqCKYbK1W/t2lqpSUx\nWO7gNi16gDJ4vealxEm3IsnUBXWNOzfCM9agSTECfz01hg/EA0A9F3r0sf/KlkTA\nX1qpXJouPaXMXbHhrU+jfQ1lZvuv1BWT4nDNt7YfdHUn7ysExBe7V4Ams7SpncMX\n2CyTQq1SK92fAvMWqAIZF7NmhMmkE5b5uVcSAnqNeNdJleiUPsX6520BkVGsatbq\nFIcdiIHDH6RbEL4gpD4=\n-----END PRIVATE KEY-----\n",
  "client_email":
      "new-vt-partner-server-key@vt-partner-8317b.iam.gserviceaccount.com",
  "client_id": "102183781280234086408",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/new-vt-partner-server-key%40vt-partner-8317b.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
};

Future<BitmapDescriptor> getMarkerIconFromUrl(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 150);
      ui.FrameInfo fi = await codec.getNextFrame();
      final data = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
    } else {
      throw Exception("Failed to load image");
    }
  } catch (e) {
    print("Error loading marker icon from URL: $e");
    return BitmapDescriptor.defaultMarker;
  }
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: blackColor,
      content: Text(
        text,
        style: bold15White,
      ),
      duration: const Duration(milliseconds: 1500),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

var customer_mobile_no = "";
var delivery_agent_mobile_no = "";
var booking_id = "";
var customerId = "";
var driverId = "";
var pickupAddress = "";
var category_id = 1;
var subCategoryID = 1;
var subCategoryName = "";
var serviceId = 1;
var serviceName = "";
var order_id = "";
var driverImage = "";
var driverName = "";

/// Converts a double precision epoch timestamp to a formatted date string
/// Format: DD/MM/YYYY, HH:MM AM/PM
String formatEpochToDateTime(double epoch) {
  // Convert epoch to milliseconds as an integer
  final int milliseconds = (epoch * 1000).toInt();
  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final DateFormat formatter = DateFormat('dd/MM/yyyy, hh:mm a');
  return formatter.format(dateTime);
}


void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    gravity: ToastGravity.TOP,
    backgroundColor:
        Colors.black.withOpacity(0.7), // Customize background color
    textColor: Colors.white, // Customize text color
    toastLength: Toast.LENGTH_SHORT, // Duration of the toast
    fontSize: 16.0, // Customize font size
  );
}

pleaseWaitDialog(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        contentPadding: const EdgeInsets.all(fixPadding * 2.0),
        insetPadding: const EdgeInsets.all(fixPadding * 2.0),
        backgroundColor: whiteColor,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            height5Space,
            SizedBox(
              height: 45,
              width: 45,
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3.0,
              ),
            ),
            heightSpace,
            heightSpace,
            Text(
              "Please wait...",
              style: regular14Grey,
            ),
            height5Space,
          ],
        ),
      );
    },
  );
}

String getDayFromDate(String dateString) {
  try {
    // Parse the string into a DateTime object
    DateTime inputDate = DateFormat("yyyy-MM-dd").parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck =
        DateTime(inputDate.year, inputDate.month, inputDate.day);

    if (dateToCheck == today) {
      // Format as "Today, 10:25 am"
      return "Today";
    } else {
      // Format as the day of the week
      return DateFormat('EEE').format(inputDate); // e.g., "Monday"
    }
  } catch (e) {
    // Handle parsing error
    return "Invalid date format";
  }
}



