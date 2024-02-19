import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({Key? key}) : super(key: key);

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  String qrResult = 'Scanned Data will appear here';
  String otpUrl = 'Scanned URL will appear here';
  String qrCode2 = 'Scanned QRcode2 will appear here';
  List<String> otpList = []; // List to store OTP codes
  Timer? otpTimer; // Timer to update OTP
  String? secretString; // Store the secret string

  @override
  void initState() {
    super.initState();
    otpTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      updateOTP();
    });
  }

  @override
  void dispose() {
    otpTimer?.cancel(); // Cancel the timer when the widget is disposeddd
    super.dispose();
  }

  Future<void> updateOTP() async {
    if (secretString != null) {
      // Generate the OTP
      final otp = OTP.generateTOTPCodeString(
          secretString!, DateTime.now().millisecondsSinceEpoch ~/ 1000,
          algorithm: Algorithm.SHA1, interval: 30);

      setState(() {
        this.qrResult = otp;
        if (this.otpList.isEmpty) {
          this.otpList.add(otp); // Add the OTP to the list if it's empty
        } else {
          this.otpList[this.otpList.length - 1] =
              otp; // Replace the last OTP with the new one
        }
      });
    }
  }

  String decodeOtpUrl(String otpUrl) {
    // Parse the otpauth:// URL
    final uri = Uri.parse(otpUrl);

    // Extract the secret key
    final secret = uri.queryParameters['secret'];

    if (secret == null) {
      return 'QR code does not contain a secret key';
    } else {
      // Decode the secret key from Base32
      final decodedSecret = base32.decode(secret);

      // Convert the decoded secret back to a string
      final secretString = base32.encode(decodedSecret);

      // Generate the OTP
      final otp = OTP.generateTOTPCodeString(
          secretString, DateTime.now().millisecondsSinceEpoch ~/ 1000,
          algorithm: Algorithm.SHA1, interval: 30, length: 6);

      return otp;
    }
  }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;

      // Print the OTP link
      setState(() {
        otpUrl = qrCode;
      });

      setState(() {
        qrCode2 = decodeOtpUrl(qrCode);
      });

      // Parse the otpauth:// URL
      final uri = Uri.parse(qrCode);

      // Extract the secret key
      final secret = uri.queryParameters['secret'];

      if (secret == null) {
        setState(() {
          qrResult = 'QR code does not contain a secret key';
        });
      } else {
        // Decode the secret key from Base32
        final decodedSecret = base32.decode(secret);

        // Convert the decoded secret back to a string
        secretString = base32.encode(decodedSecret);

        updateOTP(); // Update OTP after scanning QR
      }
    } on PlatformException {
      qrResult = 'Fail to read QR Code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$qrCode2',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              '$otpUrl',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              '$qrResult',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: scanQR, child: Text('Scan Code')),
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: otpList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      otpList[index],
                      style: TextStyle(
                        fontSize: 40,
                        color: Color.fromARGB(255, 125, 125, 125),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
