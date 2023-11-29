import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tiktok/Controllers/Auth_Controller.dart';
import 'package:tiktok/Views/Screens/add_video_screen.dart';

import 'Views/Screens/profile_screen.dart';
import 'Views/Screens/search_screen.dart';
import 'Views/Screens/video_screen.dart';

List pages = [
  VideoScreen(),
  SearchScreen(),
  const AddVideoScreen(),
  Text('Messages Screen'),
  ProfileScreen(uid: authController.user.uid),
];

// CONSTANT ARE THOSE WHICH USE FREQUENTY WITH THE WE  DONT HAVE TO WRITE EACH TIME WE WANT TP USE SOMETHING.
const backgroundColor = Colors.black;
var buttonColor = Colors.red[400];
const borderColor = Colors.grey;

// FIREBASE RELATED CONSTANST

// Now we don't need to write FirebaseAuth.instance agaqin and again all we need to write
// all we need to write is firebaseAuth.
var firebaseAuth = FirebaseAuth.instance;
var firebaseStorage = FirebaseStorage.instance;
var firestore = FirebaseFirestore.instance;

// CONTROLLERS
var authController = AuthController.instance;
