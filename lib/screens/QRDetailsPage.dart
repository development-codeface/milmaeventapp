

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:milma_group/const.dart';
import 'package:milma_group/session/shared_preferences.dart';

class QRDetailsPage extends StatefulWidget {
  final String qrCode;
  const QRDetailsPage({super.key, required this.qrCode});

  @override
  State<QRDetailsPage> createState() => _QRDetailsPageState();
}

class _QRDetailsPageState extends State<QRDetailsPage> {
  Map<String, dynamic>? qrData;
  bool isLoading = true;
  bool butisLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchQRDetails();
  }

  Future<void> _fetchQRDetails() async {
    String? accestoken = await Store.getToken();
    try {
      final response = await http.get(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accestoken',
        },
        Uri.parse(baseurl + "get_qr_details/${widget.qrCode}"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "success") {
          setState(() {
            qrData = data["data"];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: "Invalid QR Code");
        }
      } else {
        setState(() => isLoading = false);
        Fluttertoast.showToast(msg: "Failed to fetch details");
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _redeemCoupon() async {
    if (qrData == null || qrData!['id'] == null || butisLoading) return;

    setState(() => butisLoading = true);

    final redeemId = qrData!['id'];
    String? accestoken = await Store.getToken();

    try {
      final response = await http.get(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accestoken',
        },
        Uri.parse(baseurl + "redeem/$redeemId"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "success") {
          Fluttertoast.showToast(
            msg: data["message"] ?? "Redeemed successfully",
          );
          setState(() => butisLoading = false);
          Navigator.pop(context, true);
        } else {
          setState(() => butisLoading = false);
          Fluttertoast.showToast(msg: data["message"] ?? "Redeem failed");
        }
      } else {
        setState(() => butisLoading = false);
        Fluttertoast.showToast(msg: "Redeem failed");
      }
    } catch (e) {
      setState(() => butisLoading = false);
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "QR DETAILS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 17,
                weight: 5,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : qrData == null
          ? const Center(child: Text("No data found"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Coupon for : ${qrData?['Coupen'] ?? ''}",

                        style: const TextStyle(
                          fontSize: 16,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Name : ${qrData?['name'] ?? ''}",
                        style: const TextStyle(fontSize: 16, letterSpacing: 0),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Mobile number : ${qrData?['mobile'] ?? ''}",
                        style: const TextStyle(fontSize: 16, letterSpacing: 0),
                      ),

                      //const Spacer(),
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                          backgroundColor: Color(0xFF1c27b8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _redeemCoupon,
                            child: butisLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Redeem",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
