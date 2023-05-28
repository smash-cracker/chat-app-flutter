// ignore_for_file: prefer_const_constructors

import 'package:chat/auth/verify.dart';
import 'package:chat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  TextEditingController countryController = TextEditingController();
  var number = '';
  bool isFading = true;
  bool _isLoading = false;
  String phoneNumber = '';
  String verificatonId = '';
  String smsCode = '';
  int count = 0;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    countryController.text = "+91";
    super.initState();
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });

    print(verificatonId);
    print(smsCode);

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificatonId, smsCode: smsCode);

    await auth.signInWithCredential(credential);

    final user = FirebaseAuth.instance.currentUser!;

    print("auth.currentUser");
    print(auth.currentUser);

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => MyApp()));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedCrossFade(
      crossFadeState:
          isFading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(seconds: 1),
      firstChild: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 200,
            child: Image(
              image: AssetImage('assets/plane.gif'),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            margin: EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset(
                  //   'assets/phone.png',
                  //   width: 150,
                  //   height: 150,
                  // ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Phone Verification",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   "We need to register your phone before getting started!",
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: countryController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Text(
                          "|",
                          style: TextStyle(fontSize: 33, color: Colors.grey),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextField(
                          onChanged: (value) {
                            number = value;
                            print(count);
                            setState(() {
                              count = value.toString().length;
                            });
                          },
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Phone",
                          ),
                        ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary:
                              count == 10 ? Colors.pink.shade200 : Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () async {
                        if (count == 10) {
                          setState(() {
                            isFading = !isFading;
                          });
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: '${countryController.text + number}',
                            verificationCompleted:
                                (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {},
                            codeSent:
                                (String verificationId, int? resendToken) {
                              verificatonId = verificationId;
                            },
                            codeAutoRetrievalTimeout:
                                (String verificationId) {},
                          );
                        } else {
                          null;
                        }
                      },
                      child: isFading
                          ? Text("Send the code")
                          : _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : GestureDetector(
                                  onTap: login,
                                  child: Text(
                                    'vertify otp',
                                  ),
                                ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      secondChild: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/otp.png',
                width: 150,
                height: 150,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We need to register your phone before getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                showCursor: true,
                onCompleted: (pin) {
                  smsCode = pin;
                },
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.pink.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    login();
                  },
                  child: isFading
                      ? Text("Send the code")
                      : _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'vertify otp',
                            ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
