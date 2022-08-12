import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:treesensus/database/auth.dart';
import 'package:treesensus/database/database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome",
                            style: GoogleFonts.alegreya(
                                color: Colors.green, fontSize: 50),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Please Login",
                            style: GoogleFonts.alegreya(
                                color: Colors.green, fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Column(
                      children: [
                        Center(
                          child: Lottie.asset("assets/images/tree_1.json",
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              frameRate: FrameRate.max),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 150, 15, 15),
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(15),
                                // shape: MaterialStateProperty.all(
                                //   RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                // ),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.green[700]),
                                textStyle: MaterialStateProperty.all(
                                  const TextStyle(fontSize: 20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.google,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Google Sign In',
                                    style: GoogleFonts.alegreya(),
                                  ),
                                ],
                              ),
                              onPressed: submit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading == true
                  ? Container(
                      height: height,
                      width: width,
                      decoration:
                          BoxDecoration(color: Colors.black.withOpacity(0.5)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Loading',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  submit() async {
    try {
      setState(() {
        loading = true;
      });
      UserClass? user = await Auth().signInWithGoogle();
      print(user!.displayName);
      print(user.photoUrl);
      print(user.uid);
      bool checkUser = await DatabaseMethods().checkUser(user.uid);
      if (checkUser == false) {
        await DatabaseMethods().addUserData(user);
      }
    } on PlatformException catch (e) {
      print(e.toString());
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
    // print(user);
  }
}
