import 'dart:async';
import 'dart:convert';
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
  final String userNickname;
  final String chatId;
  final Iterable users;

  Contacts({Key key, @required this.currentUserId, this.userNickname, this.chatId, this.users}) : super(key: key);

  @override
  State createState() => new ContactsScreen(currentUserId: currentUserId, chatId: chatId);
}

class ContactsScreen extends State<Contacts> {
  final String currentUserId;
  final String chatId;
  ContactsScreen({Key key, @required this.currentUserId, this.chatId});

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

  Future<Null> addChatToUser(String userId, DocumentReference chat) async {
    DocumentSnapshot user = await Firestore.instance.collection("users")
        .document(userId)
        .get();

    List<dynamic> chats = (user.data.containsKey("chats")) ?
        new List<dynamic>.from(user['chats']) : new List();
    chats.add(chat);

    Firestore.instance.collection('users').document(userId).updateData({"chats": chats});
  }

  Future<Null> handleInitiation() async {

    if(selected.length > 1){
      selected.add(currentUserId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GroupInitScreen(selectedUsers: selected, userNickname: nickname, currentUserId: currentUserId,)),
      );
    } else {
      this.setState(() {
        isLoading = true;
      });

      var push_chat;

      //check existing chats
      var user1 = await Firestore.instance.collection('users').document(currentUserId).get();
      var user2 = await Firestore.instance.collection('users').document(selected.first).get();
      List chats1 = user1.data['chats'];
      List chats2 = user2.data['chats'];
      if(chats1 != null && chats2 != null) {
        for (int i = 0; i < chats1.length; i++) {
          for (int j = 0; j < chats2.length; j++) {
            if (chats1[i] == chats2[j]) {
              push_chat = chats1[i];
            }
          }
        }
      }

      if(push_chat==null) {
        var date = DateTime.now().millisecondsSinceEpoch.toString();
        var id = await Firestore.instance.collection('chats').add({
          'type': "P",
          'users': (
              [
                {
                  "id": currentUserId,
                  "join_date": date,
                },
                {
                  "id": selected.first,
                  "join_date": date,
                }
              ]
          )
        });
        await Firestore.instance
            .collection('chats')
            .document(id.documentID)
            .updateData({
          'id': id.documentID,
        });
        push_chat = id;
        addChatToUser(currentUserId, push_chat);
        addChatToUser(selected.first, push_chat);
      }

      DocumentSnapshot chat = await push_chat.get();
      final int index = chat['users'].indexWhere((val) => val['id'] == currentUserId);

      this.setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) =>
              new Chat(
                currentUserId: currentUserId,
                chatId: push_chat.documentID,
                chatAvatar: 'https://www.simplyweight.co.uk/images/default/chat/mck-icon-user.png',
                chatType: "P",
                userNickname: widget.userNickname,
                joinDate: chat['users'][index]['join_date'],
                chatName: "Private chat",
              )));
      }

  }

  Future<Null> handleAdding() async {
    this.setState(() {
      isLoading = true;
    });
     final DocumentSnapshot snapshot = await Firestore.instance
        .collection('chats')
        .document(chatId).get();
     List users = snapshot.data['users'];

     Iterator iets = selected.iterator;
     Set final_selected = new Set();
     for(int i = 0; i<selected.length;i++){
       iets.moveNext();
       if(!users.toString().contains(iets.current)){
         final_selected.add(iets.current);
       }
     }
     if(final_selected.length > 0) {
       List update = new List(users.length + final_selected.length);
       int i = 0;
       for (i; i < users.length; i++) {
         update[i] = users[i];
       }
       Iterator iterator = final_selected.iterator;
       var id = await Firestore.instance.collection('chats').document(chatId);
       for (i; i < users.length + final_selected.length; i++) {
         iterator.moveNext();
         Map m = {'id': iterator.current, 'join_date': DateTime
             .now()
             .millisecondsSinceEpoch
             .toString()};
         addChatToUser(iterator.current, id);
         update[i] = m;
       }
       await Firestore.instance
           .collection('chats')
           .document(chatId)
           .updateData({
         'users': update,
       });
       Fluttertoast.showToast(msg: "Succesful added user(s)");
     }
     else{
       Fluttertoast.showToast(msg: "No new users to add");
     }
    this.setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }



  Widget buildItem(BuildContext context, DocumentSnapshot document, index) {

    if (document['id'] == currentUserId) {
      return Container();
    } else if(widget.users != null && widget.users.contains(document['id'])) {
      return Container();
    } else {

      return new ListTile(
          onTap:null,
          leading: new CircleAvatar(
            backgroundColor: Colors.grey,
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
          if(selected.length == 0) {
            Fluttertoast.showToast(msg: "Please select contact(s)");
          }
          else if(chatId == null) {
            handleInitiation();
          }
          else {
            handleAdding();
          }
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