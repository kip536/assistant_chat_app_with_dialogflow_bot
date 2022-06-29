import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_final_app/services/constants.dart';
import 'package:my_final_app/services/services.dart';

import '../decorations/widgets.dart';



class ConversationScreen extends StatelessWidget {
  const ConversationScreen({Key? key,
    required this.currentuser, 
    required this.friendId,
    required this.friendImage,
    required this.friendName}) : super(key: key);
  final String currentuser;
  final String friendId;
  final String friendName;
  final String friendImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Avatar.small(url: friendImage),
              const SizedBox(width: 10),
              Text(
                friendName,
                style: const TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
        body: Column(children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(Constants.myUserId)
                    .collection('messages')
                    .doc(friendId)
                    .collection('chats')
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length < 1) {
                      return const Center(
                        child: Text('Say hi'),
                      );
                    }
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isMe = snapshot.data.docs[index]['senderId'] ==
                              Constants.myUserId;
                          return singlemessage(message: snapshot.data.docs[index]['message'], isMe: isMe);
                        });
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
          Messagetextfield(friendId),
        ]));
  }
}

class singlemessage extends StatelessWidget {
  final String message;
  final bool isMe;

  const singlemessage({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Bubble(
            radius: const Radius.circular(15.0),
            elevation: 0.0,
            color: isMe ? Colors.blueAccent : Colors.blueGrey[200],
            // padding: const EdgeInsets.all(16),
            // margin: const EdgeInsets.all(16),
            // constraints: const BoxConstraints(maxWidth: 200),
            // decoration: BoxDecoration(
            //   color: isMe ? Colors.blueAccent : Colors.blueGrey[200],
            //   borderRadius: const BorderRadius.all(Radius.circular(12))
            // ),
            // child: Text(message),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget> [
                  const SizedBox(width: 10,),
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints( maxWidth: 200),
                      child: Text(message, style: TextStyle(
                        color: isMe ? Colors.white : Colors.black
                        ),),
                      ),
                    )
                  ],
                ),
              ),
          ),
        )
      ],
    );
  }
}

class Messagetextfield extends StatefulWidget {
  

  const Messagetextfield(this.friendId, {Key? key}) : super(key: key);

  final String friendId;

  @override
  State<Messagetextfield> createState() => _MessagetextfieldState();
}

class _MessagetextfieldState extends State<Messagetextfield> {
  TextEditingController message_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Row(children: [
        Container(
          decoration: const BoxDecoration(
              border: Border(
                  right: BorderSide(
            width: 2,
            color: Colors.blueGrey,
          ))),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(CupertinoIcons.camera_fill, color: Colors.greenAccent),
          ),
        ),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextFormField(
                  controller: message_controller,
                  // style: input_text_style(),
                  decoration: const InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none),
                ))),
        Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 24,
          ),
          child:  GestureDetector(
          	onTap: () async {
          		String message = message_controller.text;
              message_controller.clear();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(Constants.myUserId)
                  .collection('messages')
                  .doc(widget.friendId)
                  .collection('chats')
                  .add({
                "senderId": Constants.myUserId,
                "receiverId": widget.friendId,
                "message": message,
                "text": "text",
                "date": DateTime.now(),
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(Constants.myUserId)
                    .collection('messages')
                    .doc(widget.friendId)
                    .set({
                  "last_msg": message,
                });
              });

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.friendId)
                  .collection('messages')
                  .doc(Constants.myUserId)
                  .collection('chats')
                  .add({
                "senderId": Constants.myUserId,
                "receiverId": widget.friendId,
                "message": message,
                "text": "text",
                "date": DateTime.now(),
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(Constants.myUserId)
                    .set({
                  "last_msg": message,
                });
              });
          		},
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                // color: Colors.blueGrey
                ),
              child: const Padding(
                padding: EdgeInsets.only(left: 12, right: 10),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          )
        )
      ]),
    );
  }
}