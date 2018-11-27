import 'package:chitchat/common/Environment/firestore_compatible.dart';
import 'package:meta/meta.dart';

abstract class Message implements Comparable<Message>, FirestoreCompatible {
  String _messageID;
  String get messageID => this._messageID;

  final String senderID;
  final double timestamp;

  Message({String messageID, @required this.senderID, @required this.timestamp}) {
    this._messageID = messageID;
  }

  @override
  int compareTo(Message m) {
    return this.timestamp.compareTo(m.timestamp);
  }
}

abstract class TextMessage extends Message {
  final String payload;

  TextMessage({String messageID, @required String senderID, @required double timestamp, @required this.payload}) : super(messageID: messageID, senderID: senderID, timestamp: timestamp);

  @override
  Map<String, dynamic> getTopLevelFirestoreStructure() {
    return {
      "id": this.messageID,
      "timestamp": this.timestamp,
      "type": "text",
      "payload": this.payload,
      "userFrom": this.senderID
    };
  }
}

abstract class PictureMessage extends Message {
  final String imageURL;

  PictureMessage({@required String senderID, @required double timestamp, @required this.imageURL}) : super(senderID: senderID, timestamp: timestamp);

  @override
  Map<String, dynamic> getTopLevelFirestoreStructure() {
    return {
      "id": this.messageID,
      "timestamp": this.timestamp,
      "type": "photo",
      "payload": this.imageURL,
      "userFrom": this.senderID
    };
  }
}