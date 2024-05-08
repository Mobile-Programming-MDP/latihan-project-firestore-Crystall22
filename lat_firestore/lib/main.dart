import 'package:flutter/material.dart';
import 'package:lat_firestore/user_data.dart';
import 'package:lat_firestore/user_item.dart';
import 'package:lat_firestore/user_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(UserList());
}