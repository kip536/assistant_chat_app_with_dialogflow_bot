import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/services.dart';
import 'screens.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);


  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  //this is a list to store the data acquired from database while searching
  List<Map> searchresult = [];
  bool isLoading = false;

  //implementing search functionality
  void onSearch() async {
    if (searchController.text.isEmpty) {
      setState(() {
              isLoading = false;
            });
      AnimatedSnackBar.material('please type in a username', type: AnimatedSnackBarType.info).show(context);
    } else {
      setState(() {
      //the search result should be cleared or empty after clicking search
      searchresult = [];
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .where("name", isEqualTo: searchController.text)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        AnimatedSnackBar.rectangle('info','no user found', type: AnimatedSnackBarType.info).show(context);
        //if there is no data do not show the loading indicator
        setState(() {
          isLoading = false;
          searchController.text = '';
        });
        //if there is no data it will not continue executing below code instead it will return
        return;
      }
      //this will show the details of the user
      value.docs.forEach((User) {
        //make sure the details of the user does not appear in the search list
        if (User.data()['email'] != Constants.myEmail) {
          searchresult.add(User.data());
        }
      });
      setState(() {
        isLoading = false;
      });
    });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text('search your friend')),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: TextField(
                      controller: searchController,
                      // style: input_text_style(),
                      decoration: InputDecoration(
                          hintText: 'type username.....',
                          hintStyle: TextStyle(color: Colors.white54),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      onSearch();
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 30,
                    ))
              ],
            ),
            if (searchresult.isNotEmpty)
              Expanded(
                  child: ListView.builder(
                      itemCount: searchresult.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searchresult[index]['image']),
                          ),
                          title: Text(
                            searchresult[index]['name'],
                            // style: input_text_style(),
                          ),
                          subtitle: Text(
                            searchresult[index]['email'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  searchController.text = "";
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConversationScreen(
                                                friendId: searchresult[index]
                                                    ['uid'],
                                                friendImage: searchresult[index]
                                                    ['image'],
                                                friendName: searchresult[index]
                                                    ['name'], currentuser: Constants.myUserId!)));
                              },
                              icon: Icon(
                                Icons.message,
                                color: Colors.greenAccent,
                              )),
                        );
                      }))
            else if (isLoading == true)
              Center(
                child: CircularProgressIndicator(),
              )
          ],
        ));
  }
}
