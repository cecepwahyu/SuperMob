import 'package:flutter/material.dart';
import 'package:qr_code_scannner_generator/generate_qr_code.dart';
import 'package:qr_code_scannner_generator/scan_qr_code.dart';
import 'package:otp/otp.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

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
  bool showAdditionalButtons = false;

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
              icon: Icon(
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
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: !showAdditionalButtons
                ? Colors.black.withOpacity(0.7)
                : Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
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
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Lottie.asset(
                          'assets/placeholder.json',
                          width: 250, // Adjust width as needed
                          height: 300, // Adjust height as needed
                          //SvgPicture.asset('assets/placeholder-img.svg',
                        ),
                      ),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Add 2FA Code',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 60),
                                child: Text(
                                  'Now you can add Two-Factor authentication to protect your online accounts.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                  //fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (!showAdditionalButtons)
                            Positioned.fill(
                              child: Container(
                                //color: Colors.black.withOpacity(0.5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Handle onPressed for first additional button
                                      },
                                      child: Text('Button 1'),
                                    ),
                                    const SizedBox(
                                        width:
                                            20), // Add some space between the buttons
                                    ElevatedButton(
                                      onPressed: () {
                                        // Handle onPressed for second additional button
                                      },
                                      child: Text('Button 2'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showAdditionalButtons =
                                      !showAdditionalButtons; // Toggle the boolean value
                                });
                              },
                              child: Icon(Icons.add, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(20),
                                backgroundColor:
                                    Color(0xFF33368F), // <-- Button color
                                foregroundColor:
                                    Colors.white, // <-- Splash color
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ElevatedButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       Navigator.of(context).push(
                      //         MaterialPageRoute(
                      //           builder: (context) => ScanQRCode(),
                      //         ),
                      //       );
                      //     });
                      //   },
                      //   child: Text('Scan QR Code'),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       Navigator.of(context).push(
                      //         MaterialPageRoute(
                      //           builder: (context) => GenerateQRCode(),
                      //         ),
                      //       );
                      //     });
                      //   },
                      //   child: Text('Generate QR Code'),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFF6F9FC),
    );
  }
}
