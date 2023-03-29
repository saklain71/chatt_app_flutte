import 'package:chatt_app/Screens/home_screen.dart';
import 'package:chatt_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

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
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomeScreen()));
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
