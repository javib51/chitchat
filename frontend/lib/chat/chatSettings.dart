import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/chat/chat.dart';
import 'package:chitchat/common/imageResolution.dart';
import 'package:chitchat/contacts/contacts.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/chat/chatGallery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatSettings extends StatefulWidget {
  final String chatId;
  final Future<Map<String, DocumentSnapshot>> chatUsers;
  final String chatType;
  final String currentUserId;
  final String chatName;
  final String chatAvatar;

  ChatSettings(this.chatUsers, this.chatId, this.chatType, this.currentUserId,
      this.chatName, this.chatAvatar);

  @override
  createState() => ChatSettingsState(
      currentUserId: currentUserId, chatId: chatId, chatType: chatType);
}

class ChatSettingsState extends State<ChatSettings> {
  Size deviceSize;
  Map<String, String> pictureURLs = Map<String, String>();
  ImageResolution _imageResolutionSet;
  final String currentUserId;
  final String chatId;
  final String chatType;
  ChatSettingsState(
      {Key key, @required this.currentUserId, this.chatId, this.chatType});


  List<Choice> choices = const <Choice>[
    const Choice(title: "Add Users", icon: Icons.add),
    const Choice(title: "Leave Chat", icon: Icons.delete),
  ];

  void _onItemMenuPress(Choice choice) {
    if (choice.title == "Add Users") {
      addUser();
    } else if(choice.title == "Leave Chat"){
      leaveChat();
    }
    else{
    }
  }

  Widget profileHeader() => Container(
        height: deviceSize.height / 4,
        width: double.infinity,
        color: Colors.amberAccent,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            color: Colors.amberAccent,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(width: 0.0, color: Colors.black)),
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: NetworkImage(widget.chatAvatar),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Text(
                    widget.chatName,
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget imagesCard() => Container(
        height: deviceSize.height / 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChatGallery(widget.chatId, widget.chatUsers)),
                    );
                  },
                  child: Text(
                    "Photos",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChatGallery(widget.chatId, widget.chatUsers)),
                        );
                      },
                      child: FutureBuilder(
                          future: getPreviewImages(widget.chatId),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, i) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: () {
                                      String imageName =
                                          snapshot.data.documents[i]["payload"];

                                      if (this.pictureURLs[imageName] == null) {
                                        String completeImageName = imageName;
                                        String imageResolutionMaxStringPicture =
                                            snapshot.data.documents[i]
                                                ['maxResolution'];
                                        print(
                                            "Image seen for the first time, no URL fetched.");

                                        if (imageResolutionMaxStringPicture ==
                                            null) {
                                          //Retro-compatibility
                                          print(
                                              "Downloaded an old image message that was not properly formatted.");
                                        } else if (completeImageName
                                            .startsWith("http")) {
                                          print(
                                              "Downloaded an image using the old way of sending data.");
                                        } else {
                                          ImageResolution
                                              pictureImageResolutionMax =
                                              getEnumFromString(
                                                  imageResolutionMaxStringPicture);
                                          ImageResolution localMaxResolution =
                                              this._imageResolutionSet;
                                          String prefixToPrepend = getPrefix(
                                              localMaxResolution,
                                              pictureImageResolutionMax);
                                          completeImageName =
                                              "$prefixToPrepend$completeImageName";
                                        }

                                        print("Image name: $imageName");

                                        Future.delayed(Duration(seconds: 1),
                                            () {
                                          //One second of delay because scaled-down image is not immediately ready to be downloaded.
                                          print("Timer expired.");
                                          FirebaseStorage.instance
                                              .ref()
                                              .child(completeImageName)
                                              .getDownloadURL()
                                              .then((downloadURL) {
                                            print(
                                                "URL fetched. URL: $downloadURL");
                                            this.setState(() =>
                                                this.pictureURLs[imageName] =
                                                    downloadURL);
                                          });
                                        });

                                        return Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    themeColor),
                                          ),
                                          height: 30.0,
                                          padding: EdgeInsets.all(5.0),
                                          decoration: BoxDecoration(
                                            color: greyColor2,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                          ),
                                        );
                                      } else {
                                        print(
                                            "Image already fetched previously. Downloading the image from cloud storage.");
                                        return CachedNetworkImage(
                                          placeholder: Container(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      themeColor),
                                            ),
                                            height: 30.0,
                                            padding: EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: greyColor2,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                          ),
                                          errorWidget: Material(
                                            child: Image.asset(
                                              'images/img_not_available.jpeg',
                                              height: 30.0,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          imageUrl: this.pictureURLs[imageName],
                                          height: 30.0,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                    }()),
                              );
                            } else {
                              return Container(
                                  alignment: Alignment(0.0, 0.0),
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
                                  ));
                            }
                          })),
                ),
              ),
            ],
          ),
        ),
      );

  getPreviewImages(chatId) {
    return Firestore.instance
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .where("type", isEqualTo: "photo")
        .orderBy('timestamp', descending: true)
        .limit(6)
        .getDocuments();
  }

  Widget profileColumn(user, length) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(user["photoUrl"]),
            backgroundColor: Colors.grey,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user["nickname"],
                ),
                SizedBox(
                  height: 8.0,
                ),
              ],
            ),
          )),
          /* widget.chatType == "G"
           ? IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete a user of the group',
            onPressed: () {},
          )
          : Container(), */
        ],
      ),
    );
  }

  Widget userList() => Container(
        height: deviceSize.height / 4,
        padding: const EdgeInsets.all(0.0),
        child: FutureBuilder(
            future: widget.chatUsers,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => profileColumn(
                      snapshot.data.values.toList()[index],
                      snapshot.data.values.length),
                  itemCount: snapshot.data.length,
                  reverse: true,
                );
              } else {
                return Container(
                    alignment: Alignment(0.0, 0.0),
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ));
              }
            }),
      );

  Widget usersCard() => Container(
        width: double.infinity,
        height: deviceSize.height / 2.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Users",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              userList(),
            ],
          ),
        ),
      );



  Widget bodyData() => Container(
        child: Column(
          children: <Widget>[
            profileHeader(),
            imagesCard(),
            usersCard(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;

    var menuButton;
    if(chatType == "G") {
      menuButton =  <Widget>[PopupMenuButton<Choice>(
        onSelected: _onItemMenuPress,
        itemBuilder: (BuildContext context) {
          return choices.map((Choice choice) {
            return PopupMenuItem<Choice>(
                value: choice,
                child: Row(
                  children: <Widget>[
                    Icon(
                      choice.icon,
                      color: primaryColor,
                    ),
                    Container(
                      width: 10.0,
                    ),
                    Text(
                      choice.title,
                      style: TextStyle(color: primaryColor),
                    ),
                  ],
                ));
          }).toList();
        },
      )
    ];
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT SETTINGS',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: menuButton
      ),

      body: bodyData(), //new ChatSettingsScreen(),
    );
  }

  Future<Null> deleteChatForUser(String userId, DocumentReference chat) async {
    DocumentSnapshot user =
        await Firestore.instance.collection("users").document(userId).get();

    List<dynamic> chats = (user.data.containsKey("chats"))
        ? new List<dynamic>.from(user['chats'])
        : new List();
    chats.removeWhere((el) => el.documentID == chat.documentID);

    await Firestore.instance
        .collection('users')
        .document(userId)
        .updateData({"chats": chats});
  }

  void addUser() async {
    var userList = await widget.chatUsers;
    if(chatType == "G") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>
            Contacts(currentUserId: currentUserId, chatId: chatId, users: userList.keys,)),
      );
    } else{
      Fluttertoast.showToast(msg: "Cannot add members to private chat");
    }
  }


  void leaveChat() async {
    Map<String, DocumentSnapshot> listUsers = await widget.chatUsers;
    listUsers.remove(widget.currentUserId);
    await Firestore.instance
        .collection('chats')
        .document(widget.chatId)
        .updateData({'users': listUsers.keys.toList()});
    //Check if chat is empty and delete it
    if (listUsers.isEmpty) {
      await Firestore.instance
          .collection('chats')
          .document(widget.chatId)
          .delete();
    }

    await deleteChatForUser(widget.currentUserId,
        Firestore.instance.collection('chats').document(widget.chatId));
    /*
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
    */
    var prefs = await SharedPreferences.getInstance();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                  MainScreen(currentUserId: widget.currentUserId, prefs: prefs),
            )
          );
  
  }

/*List<QuerySnapshot> getParticipants() {
    var participants = Firestore.instance
        .collection('chats')
        .document(widget.chatId)
        .collection('users')
        .snapshots()
        .toList();

    return null;
  }*/
}

class ProfileTile extends StatelessWidget {
  final title;
  final subtitle;
  final textColor;

  ProfileTile({this.title, this.subtitle, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              fontSize: 50.0, fontWeight: FontWeight.w700, color: textColor),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.normal, color: textColor),
        ),
      ],
    );
  }
}
