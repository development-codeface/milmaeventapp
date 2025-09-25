import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:milma_group/const.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  final String name;
  const SignatureScreen({Key? key, required this.name}) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? exportedImage;
  bool isUploading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final image = await _controller.toPngBytes();
      if (image != null) {
        setState(() {
          exportedImage = image;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature saved successfully!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please draw your signature first.")),
      );
    }
  }

  Future<void> _uploadSignature() async {
    if (exportedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please save your signature first.")),
      );
      return;
    }

    final connected = await checkInternetConnection();

    if (connected == false) {
      snack("Please check your connectivity", context);

      return;
    }

    try {
      setState(() {
        isUploading = true;
      });

      // Convert signature image to base64 string
      String base64Image = base64Encode(exportedImage!);

      // Replace with your API endpoint
      const String apiUrl = "https://yourserver.com/api/upload_signature";

      // Send POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "signature": base64Image,
          "user_id": "123", // You can pass extra data if needed
        }),
      );

      setState(() {
        isUploading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature uploaded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _clearSignature() {
    _controller.clear();
    setState(() {
      exportedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // align left
          children: [
            Text(
              widget.name.toUpperCase(), // convert to uppercase
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              "SIGNATURE PAD",
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
        centerTitle: true,

        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(4), // spacing inside the box
              decoration: BoxDecoration(
                color: Colors.white, // background color inside the box
                border: Border.all(color: Colors.grey, width: 1), // grey border
                borderRadius: BorderRadius.circular(8), // curved corners
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 17,
                weight: 5,
                color: primaryColor, // icon color
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Signature Canvas
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _controller,
                  height: 300,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveSignature,
                  icon: Icon(Icons.save, color: primaryColor),
                  style: ElevatedButton.styleFrom(
                    elevation: 0, // removes shadow
                    shadowColor: Colors.transparent, // ensures no shadow color
                  ),
                  label: Text("Save", style: TextStyle(color: primaryColor)),
                ),
                ElevatedButton.icon(
                  onPressed: _clearSignature,
                  icon: Icon(Icons.clear, color: primaryColor),
                  label: Text("Clear", style: TextStyle(color: primaryColor)),
                  style: ElevatedButton.styleFrom(
                    elevation: 0, // removes shadow
                    shadowColor: Colors.transparent, // ensures no shadow color
                  ),
                  //  style: ElevatedButton.styleFrom(ba),
                ),
                ElevatedButton.icon(
                  onPressed: isUploading ? null : _uploadSignature,
                  icon: Icon(Icons.cloud_upload, color: primaryColor),
                  style: ElevatedButton.styleFrom(
                    elevation: 0, // removes shadow
                    shadowColor: Colors.transparent, // ensures no shadow color
                  ),
                  label: isUploading
                      ? const Text("Uploading...")
                      : Text("Upload", style: TextStyle(color: primaryColor)),
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.green,
                  // ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Show Exported Signature Image
            if (exportedImage != null) ...[
              const Text(
                "Your Saved Signature:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Image.memory(exportedImage!, height: 150),
            ],
          ],
        ),
      ),
    );
  }
}
