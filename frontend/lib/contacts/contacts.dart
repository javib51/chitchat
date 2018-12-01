import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/contacts/groupcredits.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/chat/chat.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/login/login.dart';
import 'package:chitchat/settings/settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contacts extends StatefulWidget {
  final String currentUserId;
  Contacts({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => new ContactsScreen(currentUserId: currentUserId);
}

class ContactsScreen extends State<Contacts> {
  final String currentUserId;
  ContactsScreen({Key key, @required this.currentUserId});

  bool isLoading = false;
  Set selected = new Set();
  List checkboxlist;

  SharedPreferences prefs;

  String nickname = '';
  String photoUrl = '';


  @override
  void initState() {
    super.initState();
    createCheckbox();
    readLocal();
  }

  void createCheckbox() async {
    checkboxlist = new List(100);
    for (int i = 0; i<checkboxlist.length;i++){
      checkboxlist[i] = false;
    }
  }


  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    nickname = prefs.getString('nickname') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    // Force refresh input
    setState(() {});
  }

  void onChanged(bool value, int index, String id) {
    if(selected.contains(id)){
      selected.remove(id);
    } else{
      selected.add(id);
    }
    setState(() {
      checkboxlist[index] = value;
    });
  }

  Future<Null> handleInitiation() async {
    if(selected.length == 0) {
      Fluttertoast.showToast(msg: "Please select contact(s)");
    }
    else if(selected.length > 1){
      selected.add(currentUserId);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GroupInitScreen(selectedUsers: selected,)),
      );
    } else {
      this.setState(() {
        isLoading = true;
      });

      var push_chat;

      //check existing chats
      final CollectionReference result = await Firestore.instance
          .collection('chats');
      final QuerySnapshot order_1 = await result.where(
          'users', isEqualTo: [selected.first, currentUserId]).getDocuments();
      final QuerySnapshot order_2 = await result.where(
          'users', isEqualTo: [currentUserId, selected.first]).getDocuments();

      if(order_1.documents.length > 0) {
        push_chat = order_1.documents.first.documentID;
      }
      else if(order_2.documents.length > 0) {
        push_chat = order_2.documents.first.documentID;
      }
      else {
        var id = await Firestore.instance.collection('chats').add({
          'type': "P",
          'users': (
              [currentUserId,
              selected.first
              ]
          )
        });
        await Firestore.instance
            .collection('chats')
            .document(id.documentID)
            .updateData({
          'id': id.documentID,
        });
        push_chat = id.documentID;
      }
      this.setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) =>
              new Chat(
                currentUserId: currentUserId,
                chatId: push_chat,
                chatAvatar: 'https://www.simplyweight.co.uk/images/default/chat/mck-icon-user.png',
              )));
      }

  }



  Widget buildItem(BuildContext context, DocumentSnapshot document, index) {

    if (document['id'] == currentUserId) {
      return Container();
    } else {

      return new ListTile(
          onTap:null,
          leading: new CircleAvatar(
            backgroundColor: Colors.amber,
              backgroundImage: new NetworkImage('${document['photoUrl']}')
          ),
          title: new Row(
            children: <Widget>[
              new Expanded(

                child: new Text(
                  '${document['nickname']}',
                  style: TextStyle(color: primaryColor),
                ),
              ),
              new Checkbox(value: checkboxlist[index],activeColor: Colors.amber, onChanged: (bool value){onChanged(value, index,document['id']);})
            ],
          )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Contacts',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {

              }
          ),
        ],
      ),
      // body is the majority of the screen.
      body: WillPopScope(
        child: Stack(
            children: <Widget>[
              // List
              Container(
                child: StreamBuilder(
                    stream: Firestore.instance.collection('users').orderBy('nickname').snapshots(),
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
                            buildItem(context, snapshot.data.documents[index],index),
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
        onWillPop: null,
      ),
    floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        child: Icon(
            Icons.arrow_forward),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
        onPressed: () {
          handleInitiation();
        }
      ),
    );
  }
}

class Contact {

  String id;
  bool isCheck;

  Contact(this.id, this.isCheck);
}