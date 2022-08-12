import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:treesensus/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.green[900],
            selectionHandleColor: Colors.green[900]),
        primarySwatch: Colors.blue,
      ),
      home: splashscreen(),
    );
  }
}

class splashscreen extends StatefulWidget {
  splashscreen({Key? key}) : super(key: key);

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Wrapper(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Aurangabad',
                style: TextStyle(
                    color: Colors.green,
                    // fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Tree Census',
                style: TextStyle(
                    color: Colors.green,
                    // fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Image(
                image: AssetImage('assets/images/splash1.png'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Image(image: AssetImage('assets/images/splash2.png')),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Incipient Technologies Pvt. Ltd.',
                style: TextStyle(
                    color: Colors.black54,
                    // fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Technical Partner',
                style: TextStyle(
                    color: Colors.black54,
                    // fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
