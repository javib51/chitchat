import 'package:chitchat/common/Environment/firestore_compatible.dart';
import 'package:chitchat/common/Models/message.dart';
import 'package:meta/meta.dart';

abstract class Chat implements FirestoreCompatible {
  final String id;

  List<Message> _messages;
  List<Message> get messages => this._messages;

  Chat({@required this.id, @required List<Message> messages}) {
    this._messages = messages;
  }

  @override
  Map<String, List<MapEntry<String, Map<String, dynamic>>>> getNestedFirestoreCollections() {

    List<MapEntry<String, Map<String, dynamic>>> entries = List<MapEntry<String, Map<String, dynamic>>>();

    this.messages.forEach((message) {
      entries.add(MapEntry(message.messageID, message.getTopLevelFirestoreStructure()));
    });

    return {
      "messages": entries
    };
  }
}

class SingleChat extends Chat {
  final String participant1ID;
  final String participant2ID;

  SingleChat({@required String id, List<Message> messages=const [], @required this.participant1ID, @required this.participant2ID}) : super(id: id, messages: messages);

  @override
  Map<String, dynamic> getTopLevelFirestoreStructure() {
    return {
      "id": this.id,
      "type": "P",
      "users": [this.participant1ID, this.participant2ID]
    };
  }
}

class GroupChat extends Chat {

  Set<String> _participantsIDs;
  Set<String> get participantsIDs => this._participantsIDs;

  GroupChat({@required String id, List<Message> messages=const [], @required Set<String> participantsIDs}) : super(id: id, messages: messages) {
    this._participantsIDs = participantsIDs;
  }

  @override
  Map<String, dynamic> getTopLevelFirestoreStructure() {
    return {
      "id": this.id,
      "type": "G",
      "users": this._participantsIDs
    };
  }

}