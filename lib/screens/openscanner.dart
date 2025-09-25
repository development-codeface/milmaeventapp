import 'package:flutter/material.dart';
import 'package:milma_group/const.dart';
import 'scanner_page.dart';

class Openscanner extends StatefulWidget {
  const Openscanner({Key? key}) : super(key: key);

  @override
  State<Openscanner> createState() => _HomePageState();
}

class _HomePageState extends State<Openscanner> {
  String scannedResult = "";

  Future<void> _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (result != null && mounted) {
      setState(() {
        scannedResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Scanner",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        automaticallyImplyLeading: false,

        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(100),
            child: CircleAvatar(
              radius: 10,
              backgroundColor: primaryColor,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 17,
                weight: 5,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Scanned Result:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              scannedResult.isEmpty ? "No result yet" : scannedResult,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Open Scanner"),
            ),
          ],
        ),
      ),
    );
  }
}
