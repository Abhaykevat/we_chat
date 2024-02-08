import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/main.dart';
import 'package:we_chat/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nuser:${user.user}');
        log('\nuserAdditionalInfo:${user.additionalUserInfo}');

        if (await APIs.userExists()) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something went wrong (check internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
      ),
      body: Stack(children: [
        AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/meetme.png')),
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 223, 255, 187),
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
                icon: Image.asset(
                  'images/google.png',
                  height: mq.height * .03,
                ),
                label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                      TextSpan(text: 'login With '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ])))),
      ]),
    );
  }
}
