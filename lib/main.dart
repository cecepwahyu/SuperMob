import 'package:flutter/material.dart';
import 'package:qr_code_scannner_generator/generate_qr_code.dart';
import 'package:qr_code_scannner_generator/scan_qr_code.dart';
import 'package:otp/otp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner and Generator',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String otpCode = '';

  @override
  void initState() {
    super.initState();
    otpCode = OTP.generateTOTPCodeString("JBSWY3DPEHPK3PXP", 1362302550000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BPD Authenticator'),
        foregroundColor: Color(0xFFFFFFFF),
        backgroundColor: Color(0xFF273AE9),
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ScanQRCode()));
                });
              },
              child: Text('Scan QR Code')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GenerateQRCode()));
                });
              },
              child: Text('Generate QR Code')),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => MyApp()));
                });
              },
              child: Text('Scan QR Code2')),
          Text('OTP Code: $otpCode')
        ],
      )),
      backgroundColor: Color(0xFFF6F9FC),
    );
  }
}
