import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:otp/otp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> scanQR() async {
    String qrResult = await FlutterBarcodeScanner.scanBarcode(
        "#000000", "Cancel", true, ScanMode.QR);

    if (qrResult != "-1") {
      String otp = OTP.generateTOTPCodeString(
          qrResult, DateTime.now().millisecondsSinceEpoch,
          length: 6, interval: 30, algorithm: Algorithm.SHA1);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Generated OTP'),
            content: Text('Your OTP is: $otp'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('OTP Generator'),
        ),
        body: Center(
          child: ScanButton(scanQR: scanQR),
        ),
      ),
    );
  }
}

class ScanButton extends StatelessWidget {
  final Future<void> Function() scanQR;

  ScanButton({required this.scanQR});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: scanQR,
      child: Text('Scan QR Code'),
    );
  }
}
