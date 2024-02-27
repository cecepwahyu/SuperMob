import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_code_scannner_generator/generate_qr_code.dart';
import 'package:qr_code_scannner_generator/scan_qr_code.dart';
import 'package:otp/otp.dart';
import 'package:lottie/lottie.dart';
import 'gen/assets.gen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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

class _HomePageState extends State<HomePage> {
  String otpCode = '';
  bool showAdditionalButtons = true;
  bool isButtonRotated = false; // Keep track of the rotation state
  String otpReveal = '';
  int initialDuration = 0;

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
                      Column(
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
                                                'BPD DIY', // Change the text content as needed
                                                style: TextStyle(
                                                  color: Colors.black, // Set text color
                                                  fontSize: 20, // Set text size
                                                  fontWeight: FontWeight.bold, // Set text weight
                                                ),
                                              ),
                                              SizedBox(height: 4), // Add space between the texts
                                              Text(
                                                'user@bpddiy.co.id', // Add your second text content here
                                                style: TextStyle(
                                                  color: Colors.black, // Set text color
                                                  fontSize: 14, // Set text size
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(), // Add a spacer to push the circle to the right
                                          CircularCountDownTimer(
                                            duration: 30,
                                            initialDuration: initialDuration,
                                            // controller: CountDownController(), // You can remove the controller
                                            width: 50,
                                            height: 50,
                                            ringColor: Colors.grey,
                                            fillColor: Color(0xFF33368F),
                                            backgroundColor: Colors.transparent,
                                            strokeWidth: 5.0,
                                            strokeCap: StrokeCap.round,
                                            textStyle: const TextStyle(
                                              fontSize: 20.0,
                                              color: Color(0xFF33368F),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textFormat: CountdownTextFormat.S,
                                            isReverse: true, // Set isReverse to true to count down from duration to 0
                                            isReverseAnimation: false,
                                            isTimerTextShown: true,
                                            autoStart: true, // Set autoStart to true to start the countdown automatically
                                            onComplete: () {
                                              // Restart the countdown when it reaches 0
                                              // Set the initial duration back to 30
                                              setState(() {
                                                initialDuration = 0;
                                              });
                                            },
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
                                                constraints: BoxConstraints(
                                                  minWidth: 25, // Set the minimum width of the rectangle
                                                  minHeight: 25, // Set the minimum height of the rectangle
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEDF5FF),
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8), // Adjust padding as needed
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      otpReveal[i],
                                                      style: TextStyle(
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
                      // Stack(
                      //   alignment: Alignment.center,
                      //   children: [
                      //     otpReveal.isNotEmpty
                      //         ? Padding(
                      //       padding: const EdgeInsets.symmetric(vertical: 30),
                      //       child: Text(
                      //         otpReveal,
                      //         style: TextStyle(color: Colors.black),
                      //       ),
                      //     )
                      //         : Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Lottie.asset(
                      //           Assets.json.placeholder,
                      //           width: 250,
                      //           height: 300,
                      //         ),
                      //         const Padding(
                      //           padding: EdgeInsets.all(20),
                      //           child: Text(
                      //             'Add 2FA Code',
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 15,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //         const Padding(
                      //           padding: EdgeInsets.symmetric(horizontal: 60),
                      //           child: Text(
                      //             'Now you can add Two-Factor authentication to protect your online accounts.',
                      //             style: TextStyle(
                      //               color: Colors.grey,
                      //               fontSize: 13,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ),
                      //         const SizedBox(height: 30), // Adjust height as needed
                      //       ],
                      //     ),
                      //   ],
                      // )


                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: !showAdditionalButtons
                ? Colors.black.withOpacity(0.7)
                : Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 20, // Adjust this value to set the distance from the bottom
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAdditionalButtons = !showAdditionalButtons;
                        isButtonRotated = !isButtonRotated; // Toggle rotation state
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: const Color(0xFF33368F),
                      foregroundColor: Colors.white,
                    ),
                    child: Transform.rotate(
                      angle: isButtonRotated ? 0.8 : 0, // Rotate if isButtonRotated is true
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (!showAdditionalButtons)
                Positioned(
                  bottom: 130, // Adjust this value to set the distance from the top of the button
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle onPressed for first additional button
                          scanQR();
                        },
                        child: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      const SizedBox(width: 20), // Add some space between the buttons
                      ElevatedButton(
                        onPressed: () {
                          // Handle onPressed for second additional button
                        },
                        child: const Text('Load QR from Image', style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ],
                  ),
                ),
            ],
          ),


        ],
      ),
      backgroundColor: Color(0xFFF6F9FC),
    );
  }

  Future<String> fetchOTP() async {
    try {
      final response =
      await http.get(Uri.parse('http://10.91.6.84:8080/generateOTP'));

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
        showAdditionalButtons = true; // Close the additional buttons after successful scan
        isButtonRotated = false;
      });
      // Print the value of otpReveal
      print('OTP Revealed: $otpReveal');
    } catch (e) {
      print('Error: $e');
    }
  }
}
