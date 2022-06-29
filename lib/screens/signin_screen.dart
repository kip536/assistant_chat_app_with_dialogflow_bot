

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/services.dart';
import 'screens.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AuthMethods authMethods = AuthMethods();
  DatabaseMethods databaseMethods = DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  TextEditingController passwordTextEditingControler = TextEditingController();
  TextEditingController emailTextEditingControler = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? snapshotUserInfo;

  signMeIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    imageCache.clear();
    imageCache.clearLiveImages();
    Constants.myProfilePic.toString().endsWith('null') ?
    imageCache.clear() :
    await CachedNetworkImage.evictFromCache(Constants.myProfilePic!);
    if (formKey.currentState!.validate()) {
      HelperFunctions.saveUserEmailSharedPreference(
          emailTextEditingControler.text);
      setState(() {
        isLoading = true;
        const Center(
          child: CircularProgressIndicator(),
        );
      });
      await databaseMethods
          .getUserInfo(emailTextEditingControler.text)
          .then((value) {
        snapshotUserInfo = value;
        HelperFunctions.saveUserNameSharedPreference(
            snapshotUserInfo!.docs[0]['name']);
        HelperFunctions.saveUserImageSharedPreference(
            snapshotUserInfo!.docs[0]['image']);
      });
      await authMethods
          .signInWithEmailAndPassword(
              emailTextEditingControler.text, passwordTextEditingControler.text)
          .then((value) async {          
        if (value != null) {
          AnimatedSnackBar.material('Success', type: AnimatedSnackBarType.success).show(context);
          Constants.myProfilePic =
              await HelperFunctions.getUserImageSharedPreference();
          Constants.myName =
              await HelperFunctions.getUserNameSharedPreference();
          Constants.myEmail =
              await HelperFunctions.getUserEmailSharedPreference();
          Constants.myUserId = await HelperFunctions.getUserIdSharedPreference();
          print("we got the data + this name is  ${Constants.myName} this email is ${Constants.myEmail} and picurl is ${Constants.myProfilePic} and userid is ${Constants.myUserId}");
          await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false);
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('invalid email or password'), backgroundColor: Colors.redAccent,));
          AnimatedSnackBar.material('invalid email or password', type: AnimatedSnackBarType.error).show(context);
          setState(() {
                      isLoading = false;
                      passwordTextEditingControler.text = '';
                    });
          return;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 50,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Welcome Back',
                          style: GoogleFonts.raleway(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                              radius: 65,
                              backgroundImage: const NetworkImage(
                                  'https://www.fote.org.uk/wp-content/uploads/2017/03/profile-icon.png'),
                              foregroundImage: Constants.myProfilePic.toString().endsWith('null') ?
                              const NetworkImage(
                                  'https://www.fote.org.uk/wp-content/uploads/2017/03/profile-icon.png') :
                                  NetworkImage(Constants.myProfilePic!)),
                        ),
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (val) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val!)
                                    ? null
                                    : "please provide a valid email";
                              },
                              controller: emailTextEditingControler,
                              // TODO
                              // style: simpleTextStyle(),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 20.0),
                                  isDense: true,
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Icon(Icons.email),
                                  ),
                                  hintText: 'Email...',
                                  hintStyle: TextStyle(
                                      color: Colors.white54, fontSize: 14),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white))),
                            ),
                            TextFormField(
                              obscureText: true,
                              validator: (val) {
                                return val!.length > 6
                                    ? null
                                    : "please enter a valid password";
                              },
                              controller: passwordTextEditingControler,
                              // TODO
                              // style: simpleTextStyle(),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(top: 20.0),
                                  isDense: true,
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Icon(CupertinoIcons.lock_fill),
                                  ),
                                  hintText: 'Password...',
                                  hintStyle: TextStyle(
                                      color: Colors.white54, fontSize: 14),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: const Text(
                            "Forgot Password",
                            // TODO
                            // style: simpleTextStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          signMeIn();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xff007EF4),
                                Color(0xff2A75BC)
                              ]),
                              borderRadius: BorderRadius.circular(30)),
                          child: const Text(
                            "Sign In",
                            // TODO
                            // style: mediumTextStyle(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Text("Sign In with Google",
                            style:
                                TextStyle(color: Colors.black87, fontSize: 17)),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            // TODO
                            // style: mediumTextStyle(),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
                                  (route) => false);
                            },
                            child: Container(
                              // color: Colors.blueGrey,
                              padding: const EdgeInsets.symmetric(
                                vertical: 19,
                              ),
                              child: const Text(
                                "SignUp now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
