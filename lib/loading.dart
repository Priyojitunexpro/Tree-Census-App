import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: Center(
          child: Lottie.asset(
            "assets/images/loading.json",
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
