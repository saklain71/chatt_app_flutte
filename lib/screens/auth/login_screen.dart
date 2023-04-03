import 'dart:developer';
import 'dart:io';
import 'package:chatt_app/Screens/home_screen.dart';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/helper/dialogs.dart';
import 'package:chatt_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  _handleGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user != null){}
      log('user ${user?.user}');
      log('user Additional info ${user?.additionalUserInfo}');
      if((await APIs.userExists())){
        Navigator.push(
            context, MaterialPageRoute(builder: (context)=>  HomeScreen()));
      }else{
        await APIs.creatUser().then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context)=> HomeScreen()));
        });
      }
    });
  }


  Future<UserCredential?> _signInWithGoogle() async {
  try{
    // internet check
    await InternetAddress.lookup("google.com");
  // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    // Once signed in, return the UserCredential
    return await APIs.auth.signInWithCredential(credential);
  }catch(e){
    log("\n _signInWithGoogle $e");
    Dialogs.showSnackbar(context, "Something went wrong! check internet");
    return null;
  }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
      setState(() {
        _isAnimate = true;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: true,
        title: const Text("Welcome to We Chat"),
      ),
      body: Stack(children: [
        /// app logo
        AnimatedPositioned(
          duration: const Duration(seconds: 3),
              top: mq.height * 0.15 ,
              left: _isAnimate ?  mq.width * 0.25 :  mq.width * 0.5,
              width: mq.width * 0.5,
              child: Image.asset("images/line.png"),
        ),

        ///google login button
        Positioned(
            top: mq.height * 0.7 ,
            left: mq.width * .05,
            height: mq.height * 0.06,
            width: mq.width * 0.9,
            child: ElevatedButton.icon(
              onPressed: (){
                _handleGoogleBtnClick();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: const StadiumBorder(),
                elevation: 1
              ),
                //google icon
                icon: Image.asset('images/google.png', height: mq.height * .03),

                //login with google label
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ))),
      ],),
    );
  }
}
