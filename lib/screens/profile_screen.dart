
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../decorations/widgets.dart';
import '../services/services.dart';
import 'screens.dart';

class ProfileScreen extends StatelessWidget {
	const ProfileScreen({ Key? key }) : super(key: key);


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Colors.transparent,
				elevation: 0,
				title: const Text('My Profile'),
				),
			body: Center(
				child: Column(
					children: [
						Hero(
							tag: 'hero-profile-picture', 
							child: Avatar.large( url: Constants.myProfilePic!)),
						Padding(
							padding: const EdgeInsets.all(8),
							child: Text(Constants.myName!),
							),
						const Divider(),
						_SignOutButton()
					],
					),
				),
		);
	}
}

class _SignOutButton extends StatefulWidget {

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton> {
	final bool _loading = false;

	@override
	Widget build(BuildContext context) {
		return _loading ?
		Container(
			child: const Center(
				child: CircularProgressIndicator(),
				),
			) : TextButton(
			onPressed: () async {
				await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
	     //  SharedPreferences prefs = await SharedPreferences.getInstance();
		    // prefs.clear();
		    // imageCache!.clear();
		    // imageCache!.clearLiveImages();
		    // CachedNetworkImage.evictFromCache(Constants.myProfilePic!);
				Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInScreen()), (route) => false);
				},
			child: const Text('Sign Out'),
		);
	}
}

