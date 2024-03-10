import 'dart:convert';
import 'dart:core';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SetConst.dart';

Future<void> Auth_signin() async {
  try {
    final userCredential =
        await auth.signInAnonymously();
    print('uid:${auth.currentUser?.uid}');

  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        break;
      default:
        print(e);
        print("Unknown error.");
    }
  }
}

Future<String> GetCookie() async{
  late String Cookie;
  var token = await auth.currentUser?.getIdToken();
  final HttpsCallable callable = func.httpsCallable('createSessionCookie');
  try{
    await callable.call(token).then((result){
      Cookie = result.data['sessionCookie'];
    });
  }on FirebaseFunctionsException catch (error) {
    print(error.code);
    print(error.details);
    print(error.message);
    throw Exception('Cookie not found');
  }
  return Cookie;
}

Future<String> Safety_Sign(String Cookie, String payload) async{
  Map<String, String> senddata = {
    'cookies': Cookie,
    'payload':payload
  };
  String SignedPayload = '';
  final HttpsCallable callable = func.httpsCallable('sign');
  try {
    final HttpsCallableResult result = await callable.call(senddata);
    final data_r = result.data;
    SignedPayload = data_r['signedPayload'];
  }on FirebaseFunctionsException catch (error) {
    print(error.code);
    print(error.details);
    print(error.message);
    throw Exception('Sign failed');
  }
  return SignedPayload;
}

