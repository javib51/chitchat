import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:convert';

import 'package:chitchat/chat/chatImage.dart';

import 'package:flutter/services.dart';
import 'package:canary_recorder/canary_recorder.dart';
import 'package:flutter_permissions_helper/permissions_helper.dart';
import 'package:chitchat/chat/link_preview.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/chat/chatRecorder.dart';
import 'package:chitchat/chat/chatSettings.dart';
import 'package:chitchat/overview/overview.dart';
import 'package:chitchat/common/imageResolution.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_image_picker/asset.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';



enum ChatSide {
  left, right
}


const CHAT_SETTINGS_TEXT = "Settings/Members";

class Chat extends StatefulWidget {
  final String chatId;
  final String chatAvatar;
  final String currentUserId;
  final String userNickname;
  final String chatType;
  final String joinDate;
  final String chatName;

  Chat(
      {Key key,
        @required this.currentUserId,
        @required this.chatId,
        @required this.chatAvatar,
        @required this.userNickname,
        @required this.chatType,
        @required this.joinDate,
        @required this.chatName})
      : super(key: key);

  @override
  State createState() => new ChatState(
      currentUserId: currentUserId,
      chatId: chatId,
      chatAvatar: chatAvatar,
      userNickname: userNickname,
      chatType: chatType,
      joinDate: joinDate);
}

class ChatState extends State<Chat> {
  final String chatId;
  final String chatAvatar;
  final String currentUserId;
  final String userNickname;
  final String chatType;
  final String joinDate;

  Stream<QuerySnapshot> streamMessage;

  ChatState(
      {Key key,
        @required this.currentUserId,
        @required this.chatId,
        @required this.chatAvatar,
        @required this.userNickname,
        @required this.chatType,
        @required this.joinDate}) {
    this.streamMessage = _getMessages();
  }

  Stream<QuerySnapshot> _getMessages() {
    return Firestore.instance
        .collection('chats')
        .document(this.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .where('timestamp', isGreaterThanOrEqualTo: joinDate)
        .limit(100)
        .snapshots();
  }

  List<Choice> choices = const <Choice>[
    const Choice(title: CHAT_SETTINGS_TEXT, icon: Icons.settings),
  ];

  void _onItemMenuPress(Choice choice) {
    if (choice.title == CHAT_SETTINGS_TEXT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatSettings(this._getUsers(), chatId,
                  chatType, currentUserId, widget.chatName, chatAvatar)));
    } else {}
  }

  Future<Map<String, DocumentSnapshot>> _getUsers() async {
    DocumentSnapshot chat = await Firestore.instance
        .collection('chats')
        .document(this.chatId)
        .get();

    List<dynamic> usersList = chat['users'];
    Map<String, DocumentSnapshot> usersMap = new Map();

    for (var user in usersList) {
      var userData = await Firestore.instance
          .collection('users')
          .document(user['id'])
          .get();
      usersMap.putIfAbsent(userData["id"], () => userData);
    }

    return usersMap;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
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
          ),
        ],
      ),
      body: new ChatScreen(
        currentUserId: currentUserId,
        chatId: chatId,
        chatAvatar: chatAvatar,
        streamMessage: streamMessage,
        userNickname: userNickname,
        chatType: chatType,
        chatUsers: this._getUsers(),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatAvatar;
  final String currentUserId;
  final String userNickname;
  final String chatType;
  final Stream<QuerySnapshot> streamMessage;
  final Future<Map<String, DocumentSnapshot>> chatUsers;

  ChatScreen(
      {Key key,
        @required this.currentUserId,
        @required this.chatId,
        @required this.chatAvatar,
        @required this.userNickname,
        @required this.chatType,
        this.streamMessage,
        this.chatUsers})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(
      currentUserId: currentUserId,
      chatId: chatId,
      chatAvatar: chatAvatar,
      userNickname: userNickname,
      chatType: chatType);
}

class ChatScreenState extends State<ChatScreen> {

  String currentUserId;
  String chatId;
  String chatAvatar;
  String userNickname;
  String chatType;

  ChatScreenState(
      {Key key,
        @required this.currentUserId,
        @required this.chatId,
        @required this.chatAvatar,
        @required this.userNickname,
        @required this.chatType});

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  bool isShowEmoji;

  var recordColor;

  Map<String, String> pictureURLs = Map<String, String>();

  bool _isRecording = false;
  String _outputFile = '';

  //Load Image from Galerry
  List<Asset> images = List<Asset>();

  final TextEditingController textEditingController =
  new TextEditingController();
  ImageResolution _imageResolutionSet;

  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    recordColor = new Color(0xff203152);
    groupChatId = '';
    _isRecording = false;
    isLoading = false;
    isShowSticker = false;
    isShowEmoji = false;


    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    groupChatId = chatId;
    this._imageResolutionSet = getEnumFromString(prefs.get("photosResolution"));

    setState(() {});
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void getEmoji() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowEmoji = !isShowEmoji;
    });
  }

  final LabelDetector _detector = FirebaseVision.instance
      .labelDetector(LabelDetectorOptions(confidenceThreshold: 0.75));

  Future<String> _getLabel(File file) async {
    var options = ["Food", "Technology", "Screenshot"];
    final List<Label> labels =
    await _detector.detectInImage(FirebaseVisionImage.fromFile(file));
    String label = labels.first.label;
    if (!options.contains(label)) label = "Others";
    return label;
  }

  void onSendMessage(String payload, String type, String label) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (payload.trim() != '') {
      textEditingController.clear();

      /*Map<String, String> usersReference = new Map();
      usersReference['uid'] =  'users/' + id;*/

      Map<String, dynamic> messagePayload = {
        'userFrom':
        Firestore.instance.collection('users').document(currentUserId),
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'payload': payload,
        'type': type,
      };

      if (type == "photo") {
        messagePayload["label"] = label;
        messagePayload["nickname"] = this.userNickname;
        messagePayload["maxResolution"] = this._imageResolutionSet.toString();
      } else if (type == "text") {
        Match urlFirstMatch = _getLinkMatchFromText(payload);
        if (urlFirstMatch != null) {
          messagePayload["url"] =
              payload.substring(urlFirstMatch.start, urlFirstMatch.end);
          messagePayload["matchStart"] = urlFirstMatch.start;
          messagePayload["matchEnd"] = urlFirstMatch.end;
        }
      }

      var documentReference = Firestore.instance
          .collection('chats')
          .document(groupChatId)
          .collection('messages')
          .document(new Uuid().v4());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(documentReference, messagePayload);
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget _buildImageContainer(
      DocumentSnapshot document, bool isLastMessage, ChatSide side) {
    return Container(
      child: Material(
        child: () {
          String imageName = document["payload"];

          if (this.pictureURLs[imageName] == null) {
            String completeImageName = imageName;
            String imageResolutionMaxStringPicture = document['maxResolution'];
            print("Image seen for the first time, no URL fetched.");

            if (imageResolutionMaxStringPicture == null) {
              //Retro-compatibility
              print(
                  "Downloaded an old image message that was not properly formatted.");
            } else if (completeImageName.startsWith("http")) {
              print("Downloaded an image using the old way of sending data.");
            } else {
              ImageResolution pictureImageResolutionMax =
              getEnumFromString(imageResolutionMaxStringPicture);
              ImageResolution localMaxResolution = this._imageResolutionSet;
              String prefixToPrepend =
              getPrefix(localMaxResolution, pictureImageResolutionMax);
              completeImageName = "$prefixToPrepend$completeImageName";
            }

            print("Image name: $imageName");

            Future.delayed(Duration(seconds: side == ChatSide.left ? 1 : 0),
                    () {
                  //One second of delay because scaled-down image is not immediately ready to be downloaded.
                  print("Timer expired.");
                  FirebaseStorage.instance
                      .ref()
                      .child(completeImageName)
                      .getDownloadURL()
                      .then((downloadURL) {
                    print("URL fetched. URL: $downloadURL");
                    this.setState(() => this.pictureURLs[imageName] = downloadURL);
                  });
                });

            return Container(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
              width: 200.0,
              height: 200.0,
              padding: EdgeInsets.all(70.0),
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

            return GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatImage(this.pictureURLs[imageName]))
                );
              },
              child: CachedNetworkImage(
                placeholder: Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                  width: 200.0,
                  height: 200.0,
                  padding: EdgeInsets.all(70.0),
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
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                imageUrl: this.pictureURLs[imageName],
                width: 200.0,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            );
          }
        }(),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
      ),
      margin: EdgeInsets.only(bottom: isLastMessage ? 20.0 : 10.0, right: 10.0),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['userFrom'].documentID == currentUserId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == "text"
          // Text
              ? this._buildMessageText(
              index, document, this.isLastMessageRight(index))
              : document['type'] == "photo"
          // Image
              ? this._buildImageContainer(
              document, isLastMessageRight(index), ChatSide.right)
          // Sticker
              : Container(
            child: new Image.asset(
              'images/${document['payload']}.gif',
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                right: 10.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? FutureBuilder(
                    future: widget.chatUsers,
                    builder:
                        (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Material(
                          child: CachedNetworkImage(
                            placeholder: Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    themeColor),
                              ),
                              width: 35.0,
                              height: 35.0,
                              padding: EdgeInsets.all(10.0),
                            ),
                            imageUrl: snapshot
                                .data[document['userFrom'].documentID]
                            ["photoUrl"],
                            width: 35.0,
                            height: 35.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(18.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        );
                      } else {
                        return Container(
                          width: 35.0,
                          height: 35.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                        );
                      }
                    })
                    : Container(width: 35.0),
                document['type'] == "text"
                    ? this._buildMessageText(
                    index, document, this.isLastMessageRight(index))
                    : document['type'] == "photo"
                    ? this._buildImageContainer(
                    document, isLastMessageLeft(index), ChatSide.left)
                    : Container(
                  child: new Image.asset(
                    'images/${document['payload']}.gif',
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageLeft(index) ? 20.0 : 10.0,
                      right: 10.0),
                ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
              child: Text(
                DateFormat('dd MMM kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document['timestamp']))),
                style: TextStyle(
                    color: greyColor,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  Widget _buildMessageText(int index, DocumentSnapshot document, bool isLast) {
    String text = document["payload"];
    String url = document["url"];

      return Container(
        child: Text(
          text,
          style: TextStyle(color: primaryColor),
        ),
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        width: 200.0,
        decoration: BoxDecoration(
            color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.only(
            bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
      );
    
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1]['userFrom'].documentID !=
            listMessage[index]['userFrom'].documentID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1]['userFrom'].documentID != currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  void startRecorder() async{
    this.setState(() {
      _isRecording = true;
    });
    recordColor = Colors.red;
    await PermissionsHelper.requestPermission(Permission.RecordAudio);
    await PermissionsHelper.requestPermission(Permission.WriteExternalStorage);
    var path = await CanaryRecorder.initializeRecorder('recordertester.wav');
    await CanaryRecorder.startRecording();

    setState(() { _outputFile = path; });
  }

  void stopRecorder() async{
    this.setState(() {
      isLoading = true;
      _isRecording = false;
    });

    recordColor = new Color(0xff203152);
    await CanaryRecorder.stopRecording();
    File testFile = new File(_outputFile);
    List<int> bytes = testFile.readAsBytesSync();
    String base64 = base64Encode(bytes);
    var url = "https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyDsrc2qBpvk2XzFvRN1yD-gYr5eSZnzUmA";
    await http.post(url, body:json.encode({"config":{"languageCode":"en_US","enableWordTimeOffsets":false,"enableAutomaticPunctuation":true,"model":"video"},"audio":{"content": base64}}))

        .then((response) {
      if(response.body.length != 3) {
        var jon = Response.fromJson(json.decode(response.body));
        textEditingController.text =
            jon.results.first.alternatives.first.transcript;
      }
      else{
        Fluttertoast.showToast(msg: "recognition unsuccessful");
      }
    });

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (isShowSticker ? stickersEmojisWrapper() : Container()),

              // Input payload
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', "sticker", "sticker"),
                child: new Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: loadAssets,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 0),
              child: new IconButton(
                icon: new Icon(Icons.mic),
                onPressed: () {

                  if (!this._isRecording) {
                    return this.startRecorder();
                  }
                  this.stopRecorder();

                },
                color: recordColor,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, "text", null),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
        stream: widget.streamMessage,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget stickersEmojisWrapper() {
    return new Container(
      child: PageView(children: [
        new Container(child: galleryEmojis()),
        new Container(color: Colors.blue, child: buildSticker()),
      ]),
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  dynamic galleryEmojis() {
    print("gallery Emojis");

    var contents = rootBundle.loadString('images/emojis.json');

    return FutureBuilder(
        future: contents,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            List emojiList = jsonDecode(snapshot.data);

            return Container(
              child: new GridView.count(
                crossAxisCount: 10,
                childAspectRatio: 1,
                controller: new ScrollController(keepScrollOffset: false),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: emojiList.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      //textEditingController.text = textEditingController.text.substring(0, textEditingController.selection.start) + emoji["value"] + textEditingController.text.substring(textEditingController.selection.end);
                      textEditingController.text =
                          textEditingController.text + emoji["value"];
                    },
                    child: Container(
                      color: Colors.green,
                      margin: new EdgeInsets.all(1.0),
                      child: new Center(
                        child: new Text(
                          emoji["value"],
                          style: new TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
          }
        });
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true,
      );
      images = resultList;
    } on PlatformException catch (e) {
      error = e.message;
    }

    if (resultList.isNotEmpty) {
      setState(() {
        isLoading = true;
        images = resultList;
        if (error == null) error = 'No Error Dectected';
      });
      //Write img into a temporary file and store it
      Asset image = images[0];

      String dir = (await getTemporaryDirectory()).path;
      File temp = new File('$dir/temp.jpeg');

      ByteData data;

      switch (this._imageResolutionSet) {
        case ImageResolution.low:
          {
            data = await image.requestThumbnail(640, 480);
          }
          break;
        case ImageResolution.high:
          {
            data = await image.requestThumbnail(1280, 960);
          }
          break;
        case ImageResolution.full:
          {
            data = await image.requestOriginal();
          }
          break;
        default:
          break;
      }

      image.release();

      final buffer = data.buffer;
      await temp.writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      await _uploadFile(temp, this._imageResolutionSet);
      temp.delete();
    }
  }

  Future _uploadFile(File file, ImageResolution resolution) async {
    String contentType = lookupMimeType(file.path);
    String label = await this._getLabel(file);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask uploadTask = reference.putFile(
        file,
        StorageMetadata(contentType: contentType, customMetadata: {
          "resolution": resolution.toString().split('.').last,
        }));

    print(
        "Uploading picture sent into the chat. Picture resolution: ${resolution.toString().split('.').last}. Picture name: $fileName.");
    await uploadTask.onComplete;
    setState(() {
      isLoading = false;
    });
    onSendMessage(fileName, "photo", label);
  }

  Match _getLinkMatchFromText(String text) {
    RegExp regex = new RegExp("(?:(?:(?:https?):)?\\/\\/)" +
        "(?:\\S+(?::\\S*)?@)?" +
        "(?:" +
        "(?!(?:10|127)(?:\\.\\d{1,3}){3})" +
        "(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})" +
        "(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})" +
        "(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])" +
        "(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}" +
        "(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))" +
        "|" +
        "(?:" +
        "(?:" +
        "[a-z0-9\\u00a1-\\uffff]" +
        "[a-z0-9\\u00a1-\\uffff_-]{0,62}" +
        ")?" +
        "[a-z0-9\\u00a1-\\uffff]\\." +
        ")+" +
        "(?:[a-z\\u00a1-\\uffff]{2,}\\.?)" +
        ")" +
        "(?::\\d{2,5})?" +
        "(?:[/?#]\\S*)?");
    return regex.firstMatch(text);
  }
}
