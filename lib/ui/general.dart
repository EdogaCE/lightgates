import 'package:flutter/material.dart';

class General {
  static Widget progressIndicator(String progressMessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.black54),
        ),
        Text(progressMessage,
            style: TextStyle(fontSize: 18, color: Colors.white))
      ],
    );
  }

  static Widget decoratedButton() {
    return RaisedButton(
      onPressed: () {},
      textColor: Colors.white,
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        padding: const EdgeInsets.only(
            left: 100.0, top: 2.0, right: 100.0, bottom: 2.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text("Login", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
