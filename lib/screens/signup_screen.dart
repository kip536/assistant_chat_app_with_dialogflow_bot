
import 'dart:io';


import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/services.dart';
import 'screens.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

	@override
	_SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  AuthMethods authMethods = AuthMethods();
  DatabaseMethods databaseMethods = DatabaseMethods();


	final formKey = GlobalKey<FormState>();
	TextEditingController passwordTextEditingControler = TextEditingController();
	TextEditingController emailTextEditingControler = TextEditingController();
	TextEditingController userNameTextEditingControler = TextEditingController();
	File? _pickedImage;
  bool isLoading = false;
  String? photoUrl;


	void _pickImageCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  signMeUp () async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    imageCache.clear();
    imageCache.clearLiveImages();
    Constants.myProfilePic.toString().endsWith('null') ?
    imageCache.clear() :
    await CachedNetworkImage.evictFromCache(Constants.myProfilePic!);
  
    if (formKey.currentState!.validate()) {

      if ( _pickedImage == null) {
      print('please pick an image');
      } else {
        setState(() {
                  isLoading = true;
                });
        final ref = FirebaseStorage.instance.ref().child('users_profile_pics').child(userNameTextEditingControler.text + '.jpg');
        await ref.putFile(_pickedImage!);
        photoUrl = await ref.getDownloadURL();
        authMethods.signUpWithEmailAndPassword(userNameTextEditingControler.text, emailTextEditingControler.text, passwordTextEditingControler.text).then((value) async {
          Map<String, dynamic> userInfoMap = {
            'name': userNameTextEditingControler.text,
            'email': emailTextEditingControler.text,
            'image': photoUrl,
            'uid': Constants.myUserId,
            'date': DateTime.now()
          };

          HelperFunctions.saveUserEmailSharedPreference(emailTextEditingControler.text);
          HelperFunctions.saveUserNameSharedPreference(userNameTextEditingControler.text);
          HelperFunctions.saveUserImageSharedPreference(photoUrl!);

          databaseMethods.addUserInfo(userInfoMap);
          AnimatedSnackBar.material('Success', type: AnimatedSnackBarType.success).show(context);

          Constants.myProfilePic =
              await HelperFunctions.getUserImageSharedPreference();
          Constants.myName =
              await HelperFunctions.getUserNameSharedPreference();
          Constants.myEmail =
              await HelperFunctions.getUserEmailSharedPreference();
          Constants.myUserId = await HelperFunctions.getUserIdSharedPreference();
          print("we got the data + this name is  ${Constants.myName} this email is ${Constants.myEmail} and picurl is ${Constants.myProfilePic}");

          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SignInScreen()), (route) => false);
        });
      }
    }
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
		appBar: AppBar(
			title: const Text('Sign Up'),
			backgroundColor: Colors.transparent,
			elevation: 0,
			),
		body: isLoading ?
      Container(
        child: const Center(child: CircularProgressIndicator(),),
        ) : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 50,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.grey,
                              child: CircleAvatar(
                                radius: 65,
                                backgroundImage: const NetworkImage('https://www.fote.org.uk/wp-content/uploads/2017/03/profile-icon.png'),
                                foregroundImage: _pickedImage == null
                                    ? null
                                    : FileImage(_pickedImage!),
                              ),
                            ),
                          ),
                          Positioned(
                        top: 105,
                        left: 100,
                        child: RawMaterialButton(
                          elevation: 10,
                          fillColor: Colors.transparent,
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 30,
                            ),
                          padding: const EdgeInsets.all(9.0),
                          shape: const CircleBorder(),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                    title: const Text(
                                      'Choose Option',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: [
                                          InkWell(
                                            onTap: _pickImageCamera,
                                            splashColor: Colors.purpleAccent,
                                            child: Row(
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.camera,
                                                    color: Colors.purpleAccent,
                                                  ),
                                                ),
                                                Text(
                                                  'Camera',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: _pickImageGallery,
                                            splashColor: Colors.purpleAccent,
                                            child: Row(
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.purpleAccent,
                                                  ),
                                                ),
                                                Text(
                                                  'Gallery',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: _remove,
                                            splashColor: Colors.purpleAccent,
                                            child: Row(
                                              children: const [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.remove_circle,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.red),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                        ),
                      ),
                        ],
                      ),
                      
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) {
                                return value!.isEmpty || value.length < 4
                                    ? "please enter a valid user name"
                                    : null;
                              },
                              controller: userNameTextEditingControler,
                              // TODO
                              // style: simpleTextStyle(),
                              decoration: const InputDecoration(
                              	contentPadding: EdgeInsets.only(top: 20.0),
                              	isDense: true,
                              	prefixIcon: Padding(
                              	  padding: EdgeInsets.only(top: 20),
                              	  child: Icon(CupertinoIcons.person),
                              	),
                              	hintText: 'Username...',
                              	hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                              	focusedBorder: UnderlineInputBorder(
						                  borderSide: BorderSide(color:Colors.white),
						                  ),
						                  enabledBorder: UnderlineInputBorder(
						                    borderSide: BorderSide(color: Colors.white)
						                    )
                              	),
                            ),
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
                              	hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                              	focusedBorder: UnderlineInputBorder(
						                  borderSide: BorderSide(color:Colors.white),
						                  ),
						                  enabledBorder: UnderlineInputBorder(
						                    borderSide: BorderSide(color: Colors.white)
						                    )
                              	),
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
                              	hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                              	focusedBorder: UnderlineInputBorder(
						                  borderSide: BorderSide(color:Colors.white),
						                  ),
						                  enabledBorder: UnderlineInputBorder(
						                    borderSide: BorderSide(color: Colors.white)
						                    )
                              	),
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          signMeUp();
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
                            "Sign up",
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
                        child: const Text("Sign up with Google",
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
                            "Already have account? ",
                            // TODO
                            // style: mediumTextStyle(),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInScreen()), (route) => false);
                            },
                            child: Container(
                              // color: Colors.blueGrey,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text(
                                "Signin now",
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