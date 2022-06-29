import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/screens.dart';
import 'services.dart';

class CheckIfUserAlreadyLoggedIN extends StatefulWidget {
  const CheckIfUserAlreadyLoggedIN({Key? key}) : super(key: key);

  @override
  State<CheckIfUserAlreadyLoggedIN> createState() =>
      _CheckIfUserAlreadyLoggedINState();
}

class _CheckIfUserAlreadyLoggedINState
    extends State<CheckIfUserAlreadyLoggedIN> {
  bool isloading = false;

  getuserData() async {
    setState(() {
      isloading = true;
    });
    Constants.myUserId = await HelperFunctions.getUserIdSharedPreference();
    Constants.myProfilePic =
        await HelperFunctions.getUserImageSharedPreference();
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();

    print(
        "okey we got the data + this name is  ${Constants.myName} this email is ${Constants.myEmail} and picurl is ${Constants.myProfilePic} and userid is ${Constants.myUserId}");
    setState(() {
      isloading = false;
    });
  }

  // checknewuser() {
  //   if (Constants.myName!.isEmpty ||
  //       Constants.myProfilePic!.isEmpty ||
  //       Constants.myUserId!.isEmpty ||
  //       Constants.myEmail!.isEmpty) {
  //     setState(() {
  //       isloading = false;
  //     });
  //     return const SignUpScreen();
  //   }
  // }

  @override
  initState() {
    getuserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return Container(
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snaphot) {
              if (snaphot.connectionState == ConnectionState.waiting) {
                return Container(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (Constants.myUserId.toString().endsWith('null')) {
                print('we got nothing');
                return const SignUpScreen();
              } else if (snaphot.hasError) {
                return Container(
                  child: const Center(
                    child: Text('Something went wrong!'),
                  ),
                );
              } else if (snaphot.hasData) {
                return const HomeScreen();
              } else {
                return const SignInScreen();
              }
            }),
      );
    }
  }
}
