import 'dart:async';
import 'dart:io';
import 'dart:convert';

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
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_image_picker/asset.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
 
const CHAT_SETTINGS_TEXT = "Settings/Members";

class Chat extends StatefulWidget {
  final String chatId;
  final String chatAvatar;
  final String currentUserId;
  final String userNickname;
  final String chatType;
  Chat(
      {Key key,
      @required this.currentUserId,
      @required this.chatId,
      @required this.chatAvatar,
      @required this.userNickname,
      @required this.chatType})
      : super(key: key);

  @override
  State createState() => new ChatState(
      currentUserId: currentUserId, chatId: chatId, chatAvatar: chatAvatar, userNickname: userNickname, chatType: chatType);
}

class ChatState extends State<Chat> {
  final String chatId;
  final String chatAvatar;
  final String currentUserId;
  final String userNickname;
  final String chatType;
  Stream<QuerySnapshot> streamMessage;

  ChatState(
      {Key key,
      @required this.currentUserId,
      @required this.chatId,
      @required this.chatAvatar,
      @required this.userNickname,
      @required this.chatType}) {
      this.streamMessage = getMessages();
  }

  List<Choice> choices = const <Choice>[
    const Choice(title: CHAT_SETTINGS_TEXT, icon: Icons.settings),
  ];

  Future<Map<String, DocumentSnapshot>> getUsers() async {
    DocumentSnapshot chat = await Firestore.instance
        .collection('chats')
        .document(this.chatId)
        .get();

    List<dynamic> usersList = chat['users'];
    Map<String, DocumentSnapshot> usersMap = new Map();

    for (var user in usersList) {
      var userData =
          await Firestore.instance.collection('users').document(user).get();
      usersMap.putIfAbsent(userData["id"], () => userData);
    }

    return usersMap;
  }

  Stream<QuerySnapshot> getMessages() {
    Stream<QuerySnapshot> result = Firestore.instance
        .collection('chats')
        .document(this.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
    return result;
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == CHAT_SETTINGS_TEXT) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatSettings(this.getUsers(), chatId, chatType, currentUserId)));
    } else {}
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
            onSelected: onItemMenuPress,
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
  
  ChatScreen(
      {Key key,
      @required this.currentUserId,
      @required this.chatId,
      @required this.chatAvatar,
      @required this.userNickname,
      @required this.chatType,
      this.streamMessage})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(
      id: currentUserId, chatId: chatId, chatAvatar: chatAvatar, userNickname: userNickname, chatType: chatType);
}

class ChatScreenState extends State<ChatScreen> {
  String id;
  String chatId;
  String chatAvatar;
  String userNickname;
  String chatType;

  ChatScreenState(
      {Key key,
      @required this.id,
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
  String imageUrl;

  //Load Image from Galerry
  List<Asset> images = List<Asset>();

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    isShowEmoji = false;
    imageUrl = '';

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


  final LabelDetector detector = FirebaseVision.instance.labelDetector(
  LabelDetectorOptions(confidenceThreshold: 0.75),
  );

  Future<String> getLabel(File file) async {
    var options = ["Food", "Technology", "Screenshot"];
    final List<Label> labels = await detector.detectInImage(FirebaseVisionImage.fromFile(file));
    String label = labels.first.label;
    if(!options.contains(label)) label = "Others";
    return label;
  }

  Future uploadFile(File file) async {
  
    String contentType = lookupMimeType(file.path);
    String label = await getLabel(file);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(
        file,
        StorageMetadata(contentType: contentType, customMetadata: {
          "resolution": ImageResolution.full.toString().split('.').last,
        }));
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    setState(() {
      isLoading = false;
    });
    onSendMessage(imageUrl, "photo",label);
  }
  void onSendMessage(String payload, String type, String label) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (payload.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('chats')
          .document(groupChatId)
          .collection('messages')
          .document(new Uuid().v4());

      /*Map<String, String> usersReference = new Map();
      usersReference['uid'] =  'users/' + id;*/

      Firestore.instance.runTransaction((transaction) async {
        if (type == "photo"){
          await transaction.set(
          documentReference,
          {
            'userFrom': Firestore.instance.collection('users').document(id),
            'nickname': this.userNickname,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'payload': payload,
            'type': type,
            'label': label
          },
        );
        } else{
          await transaction.set(
          documentReference,
          {
            'userFrom': Firestore.instance.collection('users').document(id),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'payload': payload,
            'type': type
          },
        );
        }
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['userFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == "text"
              // Text
              ? Container(
                  child: Text(
                    document['payload'],
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == "photo"
                  // Image
                  ? Container(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: Container(
                            child: CircularProgressIndicator(
                              valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor),
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
                          imageUrl: document['payload'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
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
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: chatAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == "text"
                    ? Container(
                        child: Text(
                          document['payload'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == "photo"
                        ? Container(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
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
                                imageUrl: document['payload'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
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

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != id) ||
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecorderScreen()));
                },
                color: primaryColor,
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
                    onSendMessage(textEditingController.text, "text", "text"),
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
        new Container(color: Colors.red),
        new Container(color: Colors.blue),
        //galleryEmojis()
      ]),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget galleryEmojis() {
    print("gallery Emojis");
    final file = new File('/images/emojis.json').toString();
    Iterable iterable = json.decode(file);
    for (var n in iterable) {
      print(n);
    }
    //List<String> emojis = l.map((Map model)=> ;

    return Container(
      child: new GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        controller: new ScrollController(keepScrollOffset: false),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        // children: widgetList.map((String value) {
        //   return new Container(
        //     color: Colors.green,
        //     margin: new EdgeInsets.all(1.0),
        //     child: new Center(
        //       child: new Text(
        //         value,
        //         style: new TextStyle(
        //           fontSize: 50.0,
        //           color: Colors.white,
        //         ),
        //       ),
        //     ),
        //   );
        // }).toList(),
      ),
    );
  }

  Widget buildEmojis() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                onTap: () {},
                child: Text(
                  "🐣" + "😺",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30.0),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  "🐣" + "😺",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30.0),
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  "🐣" + "😺",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30.0),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(0.0),
      height: 180.0,
    );
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
      String dir = (await getTemporaryDirectory()).path;
      File temp = new File('$dir/temp.jpeg');
      ByteData data = await images[0].requestOriginal();
      final buffer = data.buffer;
      await temp.writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      await uploadFile(temp);
      temp.delete();
    }
  }
}
