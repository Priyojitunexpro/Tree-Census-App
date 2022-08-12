import 'package:flutter/material.dart';
import 'package:treesensus/database/auth.dart';
import 'package:treesensus/homepage.dart';
import 'package:treesensus/loading.dart';
import 'package:treesensus/login_page.dart';

class Wrapper extends StatelessWidget {
  Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserClass?>(
        stream: _auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            UserClass? user = snapshot.data;
            if (user == null) {
              print("=======No User===========");
              return LoginPage();
            }
            print("=======user = ${user.displayName}=====");
            return HomePage(user: user);
          } else {
            return Loading();
          }
        });
  }
}
