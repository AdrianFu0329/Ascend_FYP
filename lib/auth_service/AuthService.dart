// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<String> signUpWithPwd(
      String email, String password, String username) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential newUser = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (newUser.user != null) {
        await newUser.user!.updateDisplayName(username);
        final User? user = newUser.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'displayName': user.displayName,
              'email': user.email,
              'photoURL': user.photoURL,
            },
          );
        }
        return "Registration Successful";
      } else {
        return "Registration Failed";
      }
    } on FirebaseAuthException catch (e) {
      return ("Firebase Auth Exception: ${e.message}");
    }
  }

  Future<String> signInWithPwd(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential newUser = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (newUser.user != null) {
        final User? user = newUser.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'displayName': user.displayName,
              'email': user.email,
              'photoURL': user.photoURL ?? "",
              'description': "",
            },
          );
        }
        return "Login Successful";
      } else {
        return "Oops! Login unsuccessful!";
      }
    } on FirebaseAuthException catch (e) {
      return "Firebase Auth Exception: ${e.message}";
    }
  }

  Future<String> signInWithGoogle() async {
    String response = "";
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'displayName': user.displayName,
              'email': user.email,
              'photoURL': user.photoURL,
              'description': "",
            },
          );
        }
        response = "Login Successful";
      } else {
        response = "Oops! Login unsuccessful!";
      }
    } catch (error) {
      return error.toString();
    }
    return response;
  }
}
