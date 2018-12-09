import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/common/const.dart';
import 'package:chitchat/common/translation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:translator/translator.dart';

class TextChatElement extends StatefulWidget {
  final String text;
  final bool isLast;
  final TranslationLanguage translationLanguage;
  final bool isTranslationAutomatic;

  TextChatElement(this.text, this.isLast, this.translationLanguage,
      this.isTranslationAutomatic);

  @override
  _TextChatElementState createState() => _TextChatElementState(
      text, isLast, translationLanguage, isTranslationAutomatic);
}

class _TextChatElementState extends State<TextChatElement> {
  final String text;
  final bool isLast;
  final TranslationLanguage translationLanguage;
  final _translator = GoogleTranslator();
  final bool isTranslationAutomatic;

  Future<String> _messageTranslationFuture;

  bool _isTranslating = false;
  String _translatedMessage;

  _TextChatElementState(this.text, this.isLast, this.translationLanguage,
      this.isTranslationAutomatic);

  @override
  void initState() {
    this._messageTranslationFuture = this._getMessageTranslation();
  }

  Future<String> _getMessageTranslation() async {
    return await this
        ._translator
        .translate(this.text, to: getCountryISOCode(this.translationLanguage));
  }

  Widget _buildTranslationWidget(AsyncSnapshot<String> snapshot) {
    print("Build translation widget!");
    print("Automatic translation? ${this.isTranslationAutomatic}");
    if (this.isTranslationAutomatic) {
      print("A");
      return Column(
        children: <Widget>[
          Divider(),
          Text(
            snapshot.hasData
                ? "MESSAGE TRANSLATED TO ${getTranslationLanguageUsableString(this.translationLanguage)}\n\n ${snapshot.data}"
                : "TRANSLATING MESSAGE TO ${getTranslationLanguageUsableString(this.translationLanguage)}",
            style: TextStyle(fontStyle: FontStyle.italic, color: primaryColor),
            textAlign: TextAlign.left,
          ),
        ],
      );
    } else {
      if (!this._isTranslating && this._translatedMessage == null) {
        //Idle state for on-demand translation
        print("B");
        return Container();
      } else {
        print("C");
        return Column(
          children: <Widget>[
            Divider(),
            Text(
                !this._isTranslating
                    ? "MESSAGE TRANSLATED TO ${getTranslationLanguageUsableString(this.translationLanguage)}\n\n ${this._translatedMessage}"
                    : "TRANSLATING MESSAGE TO ${getTranslationLanguageUsableString(this.translationLanguage)}",
                style: TextStyle(fontStyle: FontStyle.italic, color: primaryColor),
                textAlign: TextAlign.left),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Called once for every message to show

    return FutureBuilder(
        future: this._messageTranslationFuture,
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          if (snapshot.hasData) {
            print(snapshot.data);
          }
          if (snapshot.error != null) {
            print(snapshot.error);
          }

          return Container(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onLongPress: () async {
                    print("LongPressed!");
                    if (this.isTranslationAutomatic) return;
                    this.setState(() {
                      this._isTranslating = true;
                    });

                    this._getMessageTranslation().then((translatedString) {
                      this.setState(() {
                        this._isTranslating = false;
                        this._translatedMessage = translatedString;
                      });
                    });
                  },
                  child: Container(
                    child: Text(
                      text,
                      style: TextStyle(color: primaryColor),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: greyColor2,
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                ),
                this._buildTranslationWidget(snapshot),
              ],
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
            margin:
                EdgeInsets.only(bottom: this.isLast ? 20.0 : 10.0, right: 10.0),
          );
        });
  }
}
