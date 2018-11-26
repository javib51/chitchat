import 'package:chitchat/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {


  @override
   createState() => ContactsScreen();
}

class ContactsScreen extends State<Contacts> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
        ],
      ),
      // body is the majority of the screen.
      body: Center(

      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        child: Icon(
            Icons.arrow_forward),
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
        onPressed: null,
      ),
    );
  }
}