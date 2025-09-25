import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final String baseurl = "https://milmasociety.cfdev.in/api/";
final String imageurl = "https://sadique.eloaa.com/uploads/";



final Color primaryColor = Color(0xFF9A221F);
 const Duration refreshInterval = Duration(minutes: 1);


 Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<void> launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> openDialer(String phoneNumber) async {
  final Uri uri = Uri.parse("tel:$phoneNumber");

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch dialer for $phoneNumber");
    }
  } catch (e) {
    print("Error launching dialer: $e");
  }
}

Future<void> openWhatsApp(String phoneNumber, {String message = ''}) async {
  // Use country code for WhatsApp, example: +91 for India
  final Uri uri = Uri.parse(
    "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw "Could not launch WhatsApp";
  }
}

Future<void> openMap(double latitude, double longitude) async {
  final Uri googleMapUrl = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude",
  );

  if (await canLaunchUrl(googleMapUrl)) {
    await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
  } else {
    throw "Could not open the map.";
  }
}

void snack(String msg, BuildContext context) {
  final snackBar = SnackBar(
    elevation: 0,
    backgroundColor: Colors.black,
    content: Text(msg, style: TextStyle(color: Colors.white)),
    behavior: SnackBarBehavior.floating,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/wifi.png",
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Internet Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
