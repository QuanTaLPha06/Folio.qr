import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
//import 'theme_constants.dart'; // Assuming you kept your theme file

class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final TextEditingController _userController = TextEditingController();
  String? _qrData;
  
  // REPLACE THIS with your actual deployed website link!
 final String _baseUrl = "https://folioqrgdg.web.app";

  void _generateQR() {
    final username = _userController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      // This creates the magic link: website.com/username
      _qrData = "$_baseUrl/$username";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13), // Dark background
      appBar: AppBar(
        title: const Text("Folio.QR Creator"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Turn your GitHub into a Portfolio",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter your username to generate a unique QR code.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // INPUT FIELD
            TextField(
              controller: _userController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1C1C23),
                hintText: "GitHub Username (e.g. kevin15)",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.person, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // GENERATE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateQR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Generate QR Code", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 50),

            // QR CODE DISPLAY AREA
            if (_qrData != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.orange.withValues(alpha:.2), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    const Text("SCAN ME", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Link: $_qrData",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }
}