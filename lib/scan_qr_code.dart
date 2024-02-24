import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:otp/otp.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:base32/base32.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late String _timeString;
  //late Timer _timer;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    //_timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() {
    //_timer.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
  }

  void _getTime() async {
    try {
      final DateTime now = await NTP.now();
      final String formattedDateTime = _formatDateTime(now);
      setState(() {
        _timeString = formattedDateTime;
      });
    } catch (e) {
      print("failed to get time: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ScanQRCode extends StatefulWidget {
  const ScanQRCode({Key? key}) : super(key: key);

  @override
  State<ScanQRCode> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  String otpReveal = 'Scanned QRcode2 will appear here';
  //Timer? otpTimer; // Timer to update OTP

  @override
  void dispose() {
    //otpTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<String> fetchOTP() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.73:8080/generateOTP'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        return jsonDecode(response.body)['otp'];
      } else {
        // If the server returns an unsuccessful response code, then throw an exception.
        throw Exception('Failed to load OTP');
      }
    } catch (e) {
      // Handle any errors that occur during the process.
      throw Exception('Failed to fetch OTP: $e');
    }
  }

  Future<bool> canConnectToServer(String serverIp, int serverPort) async {
    try {
      final response = await http.get(Uri.http('$serverIp:$serverPort', '/'));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<void> scanQR() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      if (!mounted) return;

      // Parse the otpauth:// URL
      final uri = Uri.parse(qrCode);

      // Make a GET request to the Go server to get the OTP
      final otp = await fetchOTP();
      setState(() {
        this.otpReveal = otp;
      });
    } catch (e) {
      print('Error: $e');
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
              otpReveal.isNotEmpty
                  ? otpReveal
                  : 'Scanned QRcode2 will appear here',
              style: TextStyle(color: Colors.black),
            ),
            Clock(),
            ElevatedButton(onPressed: scanQR, child: Text('Scan Code')),
            SizedBox(
              height: 30,
            ),
            Clock(),
            ElevatedButton(onPressed: scanQR, child: Text('Scan Code')),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
