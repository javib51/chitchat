import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/const.dart';
import 'package:chitchat/screens/contacts/contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class UserSearchScreen extends StatefulWidget {
  final String currentUserId;

  UserSearchScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new UserSearchScreenState(currentUserId: currentUserId);
}

class UserSearchScreenState extends State<UserSearchScreen> {
  UserSearchScreenState({Key key, @required this.currentUserId});
/*leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),*/
  final String currentUserId;

  bool isLoading = false;
  bool _isSearching = false;

  List<String> someList = [];
  List<DocumentSnapshot> users = [];
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
    // Force refresh input
    setState(() {});
  }

  void readUserInput(String text) {
    if(text.length >= 2) {
      print(text);
      performSearch(text);
      setState(() {
        someList.add(text);
      });
    }
  }

  void performSearch(String text) {
    //if(_isSearching){}
    setState(() {
      _isSearching = true;
    });
    Firestore.instance.collection('users').getDocuments().then((querySnapshot) {
      setState(() {
        _isSearching = false;
        users = [];
        querySnapshot.documents.forEach((document) {
          String nickname = document['nickname'].toString().toLowerCase();
          if (document.documentID != this.currentUserId &&
              nickname.contains(text.toLowerCase())) {
            users.add(document);
          }
        });
      });
    });
  }

  Widget getUsers() {
    if (_isSearching) {
      return Container();
    } else {
      return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            return buildItem(users[index]);
          });
    }
  }


  Widget buildItem(DocumentSnapshot user) {
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
                imageUrl: user['photoUrl'],
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
                        user['nickname'],
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Contacts(currentUserId: currentUserId,otheruser: user['id'],)),
          );
          /*Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new Chat(
                    currentUserId: currentUserId,
                    chatId: document.documentID,
                    chatAvatar: info['photoUrl'],
                  )));*/
        },
        color: greyColor2,
        padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          title: new TextField(
            onChanged: readUserInput,
            style: new TextStyle(
              color: Colors.black,
            ),
            decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search,color: Colors.black),
                hintText: "Search...",
                hintStyle: new TextStyle(color: Colors.black)
            ),
          ),
          /*leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),*/
          actions: <Widget>[

          ]
      ),
      body: getUsers()
    );
  }
}