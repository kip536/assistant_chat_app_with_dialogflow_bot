import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_final_app/decorations/widgets.dart';

import '../screens/screens.dart';
import '../services/services.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  initState() {
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myProfilePic = await HelperFunctions.getUserImageSharedPreference();
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
    Constants.myUserId = (await HelperFunctions.getUserIdSharedPreference())!;
    print(
        "we got the data + this name is  ${Constants.myName} this email is ${Constants.myEmail} and picurl is ${Constants.myProfilePic} and userid is ${Constants.myUserId}");
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: _Stories(),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, int index) {
            return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(Constants.myUserId)
          .collection('messages')
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.docs.length < 1) {
            return const Center(
              child: Text(
                'No Chats Available',
                // style: input_text_style(),
              ),
            );
          }
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                var friendId = snapshot.data.docs[index].id;
                var lastmsg = snapshot.data.docs[index]['last_msg'];
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(friendId)
                      .get(),
                  builder: (context, AsyncSnapshot asyncSnapshot) {
                    if (asyncSnapshot.hasData) {
                      var friend = asyncSnapshot.data;
                      return SizedBox(
                        height: 100,
                        width: 15,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConversationScreen(
                                          friendId: friend['uid'],
                                          friendImage: friend['image'],
                                          friendName: friend['name'],
                                          currentuser: Constants.myUserId!,
                                        )));
                          },
                          child: InkWell(
                            // onTap: () async {
                            //   await Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) => ConversationScreen(
                            //               currentuser: currentuser,
                            //               friendId: friendId,
                            //               friendImage: friendImage,
                            //               friendName: friendName)));
                            // },
                            child: Container(
                              height: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 0.2))),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child:
                                          Avatar.medium(url: friend['image']),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Text(
                                              friend['name'],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  letterSpacing: 0.2,
                                                  wordSpacing: 1.5,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                            child: Text(
                                              "$lastmsg",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textFaded),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            TimeOfDay.now().toString(),
                                            style: const TextStyle(
                                                fontSize: 11,
                                                letterSpacing: -0.2,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textFaded),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: const BoxDecoration(
                                                color: AppColors.secondary,
                                                shape: BoxShape.circle),
                                            child: const Center(
                                              child: Text(
                                                '1',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textLigth),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                );
              });
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
          },
          childCount: 1,
          ),
        )
      ],
    );
  }
}

class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: SizedBox(
        height: 134,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
              child: Text(
                'Notice Board',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textFaded),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 8,
                  itemBuilder: (buildContext, int index) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 60,
                        child: _StoryCard(
                            name: 'Car',
                            photourl:
                                'https://th.bing.com/th/id/R.57abd564bdc8ff6070e35ec4067421ab?rik=zm788oTvfxpTiA&pid=ImgRaw&r=0'),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({Key? key, required this.name, required this.photourl})
      : super(key: key);
  final String name;
  final String photourl;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 'https://firebasestorage.googleapis.com/v0/b/forth-year-prjct.appspot.com/o/users_profile_pics%2FDuncoh.jpg?alt=media&token=2f76eda6-b50f-40dc-876a-dc24cfefa5a5'
        Avatar.medium(url: photourl),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}

// class _MessageTitle extends StatefulWidget {
//   @override
//   State<_MessageTitle> createState() => _MessageTitleState();
// }

// class _MessageTitleState extends State<_MessageTitle> {


//   @override
//   initState() {
//     getUserInfogetChats();
//     super.initState();
//   }

//   getUserInfogetChats() async {
//     Constants.myName = await HelperFunctions.getUserNameSharedPreference();
//     Constants.myProfilePic =
//         await HelperFunctions.getUserImageSharedPreference();
//     Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
//     Constants.myUserId = await HelperFunctions.getUserIdSharedPreference();
//     print(
//         "we got the data + this name is  ${Constants.myName} this email is ${Constants.myEmail} and picurl is ${Constants.myProfilePic} and userid is ${Constants.myUserId}");
//   }


//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(Constants.myUserId)
//           .collection('messages')
//           .snapshots(),
//       builder: (context, AsyncSnapshot snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.data.docs.length < 1) {
//             return const Center(
//               child: Text(
//                 'No Chats Available',
//                 // style: input_text_style(),
//               ),
//             );
//           }
//           return ListView.builder(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               itemCount: snapshot.data.docs.length,
//               itemBuilder: (context, index) {
//                 var friendId = snapshot.data.docs[index].id;
//                 var lastmsg = snapshot.data.docs[index]['last_msg'];
//                 return FutureBuilder(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .doc(friendId)
//                       .get(),
//                   builder: (context, AsyncSnapshot asyncSnapshot) {
//                     if (asyncSnapshot.hasData) {
//                       var friend = asyncSnapshot.data;
//                       return SizedBox(
//                         height: 100,
//                         width: 15,
//                         child: GestureDetector(
//                           onTap: () async {
//                             await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ConversationScreen(
//                                           friendId: friend['uid'],
//                                           friendImage: friend['image'],
//                                           friendName: friend['name'],
//                                           currentuser: Constants.myUserId!,
//                                         )));
//                           },
//                           child: InkWell(
//                             // onTap: () async {
//                             //   await Navigator.push(
//                             //       context,
//                             //       MaterialPageRoute(
//                             //           builder: (context) => ConversationScreen(
//                             //               currentuser: currentuser,
//                             //               friendId: friendId,
//                             //               friendImage: friendImage,
//                             //               friendName: friendName)));
//                             // },
//                             child: Container(
//                               height: 100,
//                               margin: const EdgeInsets.symmetric(horizontal: 8),
//                               decoration: const BoxDecoration(
//                                   border: Border(
//                                       bottom: BorderSide(
//                                           color: Colors.grey, width: 0.2))),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(4),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.all(10),
//                                       child:
//                                           Avatar.medium(url: friend['image']),
//                                     ),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 8),
//                                             child: Text(
//                                               friend['name'],
//                                               overflow: TextOverflow.ellipsis,
//                                               style: const TextStyle(
//                                                   letterSpacing: 0.2,
//                                                   wordSpacing: 1.5,
//                                                   fontWeight: FontWeight.w900),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 20,
//                                             child: Text(
//                                               "$lastmsg",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: AppColors.textFaded),
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(right: 20),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           const SizedBox(
//                                             height: 4,
//                                           ),
//                                           Text(
//                                             TimeOfDay.now().toString(),
//                                             style: const TextStyle(
//                                                 fontSize: 11,
//                                                 letterSpacing: -0.2,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: AppColors.textFaded),
//                                           ),
//                                           const SizedBox(
//                                             height: 8,
//                                           ),
//                                           Container(
//                                             width: 18,
//                                             height: 18,
//                                             decoration: const BoxDecoration(
//                                                 color: AppColors.secondary,
//                                                 shape: BoxShape.circle),
//                                             child: const Center(
//                                               child: Text(
//                                                 '1',
//                                                 style: TextStyle(
//                                                     fontSize: 10,
//                                                     color: AppColors.textLigth),
//                                               ),
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }
//                     return const LinearProgressIndicator();
//                   },
//                 );
//               });
//         }
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//   }
// }
