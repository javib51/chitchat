import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/contacts/contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/chat/chat.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/login/login.dart';
import 'package:chitchat/userSearch/search.dart';
import 'package:chitchat/settings/settings.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';



class MainScreen extends StatefulWidget {
  final String currentUserId;

  MainScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {
  MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;

  bool isLoading = false;

  Map<String,Map<String,String>> values = new Map();
  SharedPreferences prefs;

  String nickname = '';
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    nickname = prefs.getString('nickname') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    String notificationToken = prefs.getString('notificationToken') ?? '';
    if(notificationToken != '') {
      updateToken(notificationToken);
    }
    // Force refresh input
    setState(() {});
  }

  void updateToken(String notificationToken) async {
    Firestore.instance.collection('users').document(currentUserId).updateData({"notificationToken": notificationToken});
  }
  
  Stream<QuerySnapshot> getChats() {
    return Firestore.instance.collection('chats')
        .where("users",  arrayContains: currentUserId).snapshots();
  }

  Future<Map<String, String>> getChatInfo(DocumentSnapshot chat) async {
    Map<String, String> map = new Map();
    if(chat['type'] == 'G') {
      map['photoUrl'] =
      "https://www.simplyweight.co.uk/images/default/chat/mck-icon-group.png";
      map['name'] = chat['name'];
    } else {
      String userId = (chat['users'][0] == currentUserId)? chat['users'][1] : chat['users'][0];
      DocumentSnapshot user = await Firestore.instance.collection('users').document(userId).get();
      map['photoUrl'] = user['photoUrl'];
      map['name'] = user['nickname'];
    }
    return map;
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Widget buildItemFuture(BuildContext context, DocumentSnapshot document) {
    return FutureBuilder(
        future: getChatInfo(document),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return buildItem(context, document, snapshot.data);
          } else {
            return Container();
          }
        }
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document, Map<String, String> info) {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    width: 50.0,
                    height: 50.0,
                    padding: EdgeInsets.all(15.0),
                  ),
                  imageUrl: info['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              new Flexible(
                child: Container(
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        child: Text(
                          info['name'],
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new Chat(
                          currentUserId: currentUserId,
                          chatId: document.documentID,
                          chatAvatar: info['photoUrl'],
                        )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
  }

  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();

    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChitChat',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserSearchScreen(currentUserId: this.currentUserId,)),
              );
            }
          ),
        ],
      ),
      drawer: new Drawer(
        child: ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(nickname),
              accountEmail: new Text(""),
              currentAccountPicture: new CircleAvatar(
                backgroundImage: new NetworkImage(photoUrl)
              ),
            ),
            new ListTile(
              title: new Text('New Chat'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Contacts()),
                );
              }
            ),
            new Divider(
              color: Colors.black,
              height: 5.0,
            ),
            new ListTile(
              title: new Text('Settings'),
              onTap: (){
                Navigator.of(context).pop();
                Navigator.push(
                context, MaterialPageRoute(builder: (context) => Settings()));
              },
            ),
            new Divider(
              color: Colors.black,
              height: 5.0,
            ),
            new ListTile(
              title: new Text('Log out'),
              onTap: (){
                handleSignOut();
              },
            ),
          ],
        ),
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: getChats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItemFuture(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        child: Icon(
            Icons.add),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Contacts()),
          );
        }
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}