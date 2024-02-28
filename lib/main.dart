import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scannner_generator/generate_qr_code.dart';
import 'package:qr_code_scannner_generator/scan_qr_code.dart';
import 'package:otp/otp.dart';
import 'package:lottie/lottie.dart';
import 'gen/assets.gen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

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
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

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
      style: const TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  String otpCode = '';
  bool showAdditionalButtons = true;
  bool isButtonRotated = false; // Keep track of the rotation state
  String otpReveal = '';
  String accountReveal = '';
  String issuerReveal = '';
  int initialDuration = 0;
  Timer? otpTimer; // Timer to update OTP
  late String _timeString = ''; // Initialize _timeString with an empty string
  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Color(0xFF33368F),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                // Add functionality for the first button
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
            const Text(
              'BPD Authenticator',
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              onPressed: () {
                // Add functionality for the third button
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 15.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Account',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          otpReveal.isNotEmpty
                              ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(20), // Adjust the padding values as needed
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Change the color as needed
                                      borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1), // Set shadow color
                                          spreadRadius: 1, // Set spread radius
                                          blurRadius: 2, // Set blur radius
                                          offset: Offset(0, 5), // Set offset
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0), // Add padding to the text
                                      child: Align(
                                        alignment: Alignment.topLeft, // Align text to the top-left corner
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      issuerReveal, // Change the text content as needed
                                                      style: const TextStyle(
                                                        color: Colors.black, // Set text color
                                                        fontSize: 20, // Set text size
                                                        fontWeight: FontWeight.bold, // Set text weight
                                                      ),
                                                    ),
                                                    SizedBox(height: 4), // Add space between the texts
                                                    Text(
                                                      accountReveal, // Add your second text content here
                                                      style: const TextStyle(
                                                        color: Colors.black, // Set text color
                                                        fontSize: 14, // Set text size
                                                        fontWeight: FontWeight.w100,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(), // Add a spacer to push the circle to the right
                                                Text(_timeString,
                                                  style: const TextStyle(
                                                    fontSize: 20.0,
                                                    color: Color(0xFF33368F),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 10), // Add space between the texts
                                            Row(
                                              children: [
                                                for (int i = 0; i < otpReveal.length; i++)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8), // Adjust horizontal padding as needed
                                                    child: Container(
                                                      constraints: const BoxConstraints(
                                                        minWidth: 25, // Set the minimum width of the rectangle
                                                        minHeight: 25, // Set the minimum height of the rectangle
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEDF5FF),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8), // Adjust padding as needed
                                                        child: Align(
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            otpReveal[i],
                                                            style: const TextStyle(
                                                              color: Color(0xFF33368F),
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )


                              ]
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                Assets.json.placeholder,
                                width: 250,
                                height: 300,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Add 2FA Code',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 60),
                                child: Text(
                                  'Now you can add Two-Factor authentication to protect your online accounts.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 30), // Adjust height as needed
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        overlayStyle: ExpandableFabOverlayStyle(
          blur: 1.0,
        ),
        children: [
          GestureDetector(
            onTap: () {
              // Your action when the text button is tapped
              scanQR();
            },
            child: Row(
              children: [
                Text('Scan QR'), // Text to display
                SizedBox(width: 8), // Adjust spacing between text and icon
                FloatingActionButton.small(
                  heroTag: null,
                  child: const Icon(Icons.camera),
                  onPressed: () {
                    scanQR();
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {

            },
            child: Row(
              children: [
                Text('Attach File'), // Text to display
                SizedBox(width: 8), // Adjust spacing between text and icon
                FloatingActionButton.small(
                  heroTag: null,
                  child: const Icon(Icons.attach_file_outlined),
                  onPressed: () {

                  },
                ),
              ],
            ),
          ),

        ],
      ),


      backgroundColor: Color(0xFFF6F9FC),
    );
  }

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    startTimer();
    _fetchTime(); // Fetch time when widget initializes
    // Update time every second
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _fetchTime());
  }

  void startTimer() {
    // Update the OTP immediately
    fetchNewOTP();
    // Schedule the subsequent fetches every second
    otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchNewOTP();
    });
  }

  void _fetchTime() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.100.73:8080/time'));
      if (response.statusCode == 200) {
        final timeMap = jsonDecode(response.body);
        final String serverTime = timeMap['time'];

        // Split the time string by ":" to get individual components
        List<String> timeComponents = serverTime.split(':');

        // Extract only the seconds part (the third component)
        String seconds = timeComponents.length >= 3 ? timeComponents[2] : '';

        // Remove any timezone information
        if (seconds.contains('+')) {
          seconds = seconds.substring(0, seconds.indexOf('+'));
        }

        // Parse seconds value and ensure it's not null
        int? parsedSeconds = int.tryParse(seconds);
        int reversedSeconds = 30; // Start the counter from 30

        if (parsedSeconds != null) {
          // Reverse the seconds count
          reversedSeconds = 30 - (parsedSeconds % 30);
        }

        // Update the state with the reversed seconds
        setState(() {
          _timeString = reversedSeconds.toString();
        });
      } else {
        throw Exception('Failed to load time');
      }
    } catch (e) {
      print("Failed to get time: $e");
    }
  }


  Future<Map<String, dynamic>> fetchOTP() async {
    try {
      final response =
      await http.get(Uri.parse('http://192.168.100.73:8080/generateOTP'));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        var jsonResponse = jsonDecode(response.body);
        return {
          'otp': jsonResponse['otp'],
          'accountName': jsonResponse['accountName'],
          'issuerName': jsonResponse['issuerName'],
        };
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
        final newAccount = jsonDecode(response.body)['accountName'];
        final newIssuer = jsonDecode(response.body)['issuerName'];
        setState(() {
          otpReveal = newOTP; // Update the OTP
          accountReveal = newAccount; // Update the OTP
          issuerReveal = newIssuer; // Update the OTP
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
        this.otpReveal = otp as String;
      });
      // Print the value of otpReveal
      print('OTP Revealed: $otpReveal');
    } catch (e) {
      print('Error: $e');
    }
  }
}
