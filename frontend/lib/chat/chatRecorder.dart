import 'package:chitchat/const.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'dart:io';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';


class RecorderScreen extends StatefulWidget {
  @override
  RecorderScreenState createState() => new RecorderScreenState();
}

class RecorderScreenState extends State<RecorderScreen> {
  bool _isRecording = false;
  StreamSubscription _recorderSubscription;
  FlutterSound flutterSound;

  String _recorderTxt = '00:00:00';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
  }

  void startRecorder() async{
    try {
      String path = await flutterSound.startRecorder(null);
      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async{
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(

    children: <Widget>[
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Sound Recorder'),
        ),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 24.0, bottom:16.0),
                    child: Text(
                      this._recorderTxt,
                      style: TextStyle(
                        fontSize: 48.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 60.0,
                    height: 60.0,
                    child: ClipOval(
                      child: FlatButton(
                        onPressed: () {
                          if (!this._isRecording) {
                            return this.startRecorder();
                          }
                          this.stopRecorder();
                        },
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.mic,
                          color: Colors.black,
                          size: 60.0,
                        ),
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 64.0),
                child: FlatButton(
                    child: Text(
                      'SEND',
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                    onPressed: () {
                      if (!this._isRecording) {
                        return this.startRecorder();
                      }
                      this.stopRecorder();
                    },
                    color: Colors.amber,
                    highlightColor: Colors.blueGrey,
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
              )
            ],
          ),
        )
      ),
      Positioned(
        child: isLoading
            ? Container(
          child: Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
          ),
          color: Colors.white.withOpacity(0.8),
        )
            : Container(),
      ),
    ],
    );
  }
}