import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserClass {
  final String uid;
  int totalTrees;
  String? photoUrl;
  String? displayName;
  String? email;
  UserClass({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    this.totalTrees = 0,
  });

  factory UserClass.fromMap(Map<String, dynamic> data) {
    return UserClass(
        uid: data['uid'],
        photoUrl: data['photoUrl'],
        displayName: data['displayName'],
        email: data['email'],
        totalTrees: data['totalTrees']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'email': email,
      'totalTrees': totalTrees,
    };
  }
}

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserClass? _userFromFirebase(User? user) {
    return user != null
        ? UserClass(
            uid: user.uid,
            displayName: user.displayName,
            photoUrl: user.photoURL,
            email: user.email)
        : null;
  }

  Stream<UserClass?> get onAuthStateChanged {
    return _auth.authStateChanges().map(_userFromFirebase);
  }

  Future<UserClass?> currentUser() async {
    final user = await _auth.currentUser;
    return _userFromFirebase(user);
  }

  Future<UserClass?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final authResult = await _auth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: googleAuth.idToken,
                accessToken: googleAuth.accessToken));
        print("Logged In");
        print(authResult.user!.email);
        return _userFromFirebase(authResult.user);
      } else {
        throw PlatformException(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          details: 'Missing google auth token',
        );
      }
    } else {
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        details: 'Sign In Aborted By User',
      );
    }
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
