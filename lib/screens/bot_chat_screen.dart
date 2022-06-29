
import 'package:bubble/bubble.dart';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:dialogflow_flutter/language.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/services.dart';

class BotChatPage extends StatefulWidget {
  const BotChatPage({ Key? key }) : super(key: key);

  @override
  State<BotChatPage> createState() => _BotChatPageState();
}

class _BotChatPageState extends State<BotChatPage> {
  void response(query) async {
    AuthGoogle authGoogle = await AuthGoogle(
        fileJson: "assets/images/services.json")
        .build();
    DialogFlow dialogflow =
    DialogFlow(authGoogle: authGoogle, language: Language.english);
    AIResponse aiResponse = await dialogflow.detectIntent(query);
    setState(() {
      messsages.insert(0, {
        "data": 0,
        "message": aiResponse.getListMessage()![0]["text"]["text"][0].toString()
      });
    });


    print(aiResponse.getListMessage()![0]["text"]["text"][0].toString());
   }

  final messageInsert = TextEditingController();
  List<Map> messsages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bot Assistant",
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text("Today, ${DateFormat("Hm").format(DateTime.now())}", style: const TextStyle(
              color: Colors.white,
              fontSize: 20
            ),),
          ),
          Flexible(
              child: ListView.builder(
                  reverse: true,
                  itemCount: messsages.length,
                  itemBuilder: (context, index) => chat(
                      messsages[index]["message"].toString(),
                      messsages[index]["data"]))),
          const SizedBox(
            height: 20,
          ),

          const Divider(
            height: 5.0,
            color: Colors.greenAccent,
          ),
          ListTile(

              leading: IconButton(
                onPressed: () {
                  //TODO:
                },
                icon: const Icon(Icons.camera_alt, color: Colors.greenAccent, size: 35,),
              ),

              title: Container(
                height: 35,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(
                      15)),
                  color: Color.fromRGBO(220, 220, 220, 1),
                ),
                padding: const EdgeInsets.only(left: 15),
                child: TextFormField(
                  controller: messageInsert,
                  decoration: const InputDecoration(
                    hintText: "Enter a Message...",
                    hintStyle: TextStyle(
                        color: Colors.black26
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),

                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black
                  ),
                  onChanged: (value) {

                  },
                ),
              ),

              trailing: IconButton(

                  icon: const Icon(

                    Icons.send,
                    size: 30.0,
                    color: Colors.greenAccent,
                  ),
                  onPressed: () {

                    if (messageInsert.text.isEmpty) {
                      print("empty message");
                    } else {
                      setState(() {
                        messsages.insert(0,
                            {"data": 1, "message": messageInsert.text});
                      });
                      response(messageInsert.text);
                      messageInsert.clear();
                    }
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  }),

          ),

          const SizedBox(
            height: 15.0,
          )
        ],
      ),
    );
  }

  //for better one i have use the bubble package check out the pubspec.yaml

  Widget chat(String message, int data) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),

      child: Row(
          mainAxisAlignment: data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [

            data == 0 ? SizedBox(
              height: 60,
              width: 60,
              child: CircleAvatar(
                radius: 19,
                child: Image.asset("assets/images/robot.png"),
              ),
            ) : Container(),

        Padding(
        padding: const EdgeInsets.all(10.0),
        child: Bubble(
            radius: const Radius.circular(15.0),
            color: data == 0 ? const Color.fromRGBO(23, 157, 139, 1) : Colors.orangeAccent,
            elevation: 0.0,

            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  const SizedBox(
                    width: 10.0,
                  ),
                  Flexible(
                      child: Container(
                        constraints: const BoxConstraints( maxWidth: 200),
                        child: Text(
                          message,
                          style: const TextStyle(
                              color: Colors.white),
                        ),
                      ))
                ],
              ),
            )),
      ),


            data == 1? SizedBox(
              height: 60,
              width: 60,
              child: CircleAvatar(
                backgroundImage: NetworkImage(Constants.myProfilePic!),
              ),
            ) : Container(),

          ],
        ),
    );
  }
}