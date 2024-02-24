import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Clock extends StatefulWidget {
  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _getTime(); // Fetch time when widget initializes
    // Update time every second
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
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
      final response =
          await http.get(Uri.parse('http://192.168.100.73:8080/time'));
      if (response.statusCode == 200) {
        final timeMap = jsonDecode(response.body);
        final String serverTime = timeMap['time'];
        setState(() {
          _timeString = serverTime;
        });
      } else {
        throw Exception('Failed to load time');
      }
    } catch (e) {
      print("Failed to get time: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString ?? 'Loading...',
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
  Timer? otpTimer; // Timer to update OTP

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    startTimer();
  }

  @override
  void dispose() {
    otpTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void startTimer() {
    // Update the OTP immediately
    fetchNewOTP();
    // Schedule the subsequent fetches every second
    otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchNewOTP();
    });
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

  Future<void> fetchNewOTP() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.73:8080/generateOTP'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        final newOTP = jsonDecode(response.body)['otp'];
        setState(() {
          otpReveal = newOTP; // Update the OTP
        });
      } else {
        // If the server returns an unsuccessful response code, then throw an exception.
        throw Exception('Failed to load OTP');
      }
    } catch (e) {
      // Handle any errors that occur during the process.
      print('Failed to fetch new OTP: $e');
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
            ElevatedButton(onPressed: scanQR, child: Text('Scan Code')),
            SizedBox(
              height: 30,
            ),
            Clock(), // Display synchronized time
          ],
        ),
      ),
    );
  }
}
