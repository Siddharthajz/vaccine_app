import 'package:flutter/cupertino.dart';

class LocalNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  LocalNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}