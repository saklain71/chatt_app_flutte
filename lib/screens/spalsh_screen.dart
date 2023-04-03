import 'dart:developer';
import 'package:chatt_app/api/apis.dart';
import 'package:chatt_app/main.dart';
import 'package:chatt_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';


//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  bool isAnimation = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
     setState(() {
       isAnimation = true;
     });
     Future.delayed(const Duration(seconds: 2), () {
       //exit full-screen
       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
       SystemChrome.setSystemUIOverlayStyle(
           const SystemUiOverlayStyle(
           systemNavigationBarColor: Colors.white,
           statusBarColor: Colors.transparent));

       // if (APIs.auth.currentUser != null) {
       //   log('\nUser: ${APIs.auth.currentUser}');
       //   //navigate to home screen
       //   Navigator.pushReplacement(
       //       context, MaterialPageRoute(builder: (_) => const HomeScreen()));
       // } else {
       //   //navigate to login screen
       //   Navigator.pushReplacement(
       //       context, MaterialPageRoute(builder: (_) => const LoginScreen()));
       // }

       if(APIs.auth.currentUser != null){
         log('user ${APIs.auth.currentUser}');
         /// navigate to homescreen
         Navigator.pushReplacement(
             context, MaterialPageRoute(builder: (_) => const HomeScreen()));
       }else{
         /// navigate to login screen
         Navigator.pushReplacement(
             context, MaterialPageRoute(builder: (_) => const LoginScreen()));
       }

       Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (_) => const HomeScreen()));
     });
    });

  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        //body
        body: Stack(children: [
          //app logo
          AnimatedPositioned(
            duration: Duration(milliseconds: 500),
                top: mq.height * .15,
                right: isAnimation ? mq.width * .25 : -mq.width * .5,
                width: mq.width * .5,
                child: Image.asset('images/line.png')),

          //google login button
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text('BdCom Product 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 19, color: Colors.black87, letterSpacing: .5))),
        ]),
      ),
    );
  }
}