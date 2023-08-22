import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tourly/controllers/auth_controller/hadleUser.dart';
import 'package:tourly/models/user_model.dart';
import 'package:tourly/views/auth_page/login_page.dart';
import 'package:tourly/views/home_page.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final box = GetStorage();
  Rx<bool> passwordVisible = false.obs;
  late Rx<bool> isRememberLogin;
  Rx<bool> loginSuccess = false.obs;

  final formKeySignIn = GlobalKey<FormState>();

  late TextEditingController usernameController;
  late TextEditingController passwordController;

  late UserModel userModel;
  RxString token = ''.obs;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    usernameController = TextEditingController(text: box.read("username"));
    passwordController = TextEditingController(text: box.read("password"));
    isRememberLogin = ((box.read("username") != null) && (box.read("password") != null)).obs;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    usernameController.dispose();
    passwordController.dispose();
  }

  void rememberLogin() {
    if (formKeySignIn.currentState!.validate()) {
      if (isRememberLogin.value) {
        box.write('username', usernameController.text);
        box.write('password', passwordController.text);
      } else {
        box.remove('username');
        box.remove('password');
      }
    }
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    rememberLogin();

    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: usernameController.value.text, password: passwordController.value.text);

      User? user = firebaseAuth.currentUser;
      userModel = UserModel(user?.uid, user?.email, user?.displayName, user?.photoURL);
      final userRef = FirebaseFirestore.instance.collection('0users').doc(user?.email);
      final documentSnapshot = await userRef.get();
      if (documentSnapshot.exists) {
        print('Tài liệu đã tồn tại!');
        final data = documentSnapshot.data();
        final dataConvert = data as Map;
        userModel = UserModel.fromJson(dataConvert);
      } else {
        print('Tài liệu không tồn tại.');
      }

      // MyData.conversationMessages = await Handle().readSection(userCustom.id);
      Get.offAll(HomePage());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Không tìm thấy người dùng với địa chỉ email này.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Địa chỉ email không hợp lệ.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Mật khẩu không đúng.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      print(
          'googleSignInAuthentication: ${googleSignInAuthentication.accessToken}\n ${googleSignInAuthentication.idToken}');
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);
        user = userCredential.user;

        // await prefs.setString('key_save_emailGG', googleSignInAuthentication.accessToken!);
        // await prefs.setString('key_save_passwordGG', googleSignInAuthentication.idToken!);

        userModel = UserModel(user?.uid, user?.email, user?.displayName, user?.photoURL);
        final userRef = FirebaseFirestore.instance.collection('0users').doc(user?.email ?? '');
        final documentSnapshot = await userRef.get();
        if (documentSnapshot.exists) {
          print('Tài liệu đã tồn tại!');
          final data = documentSnapshot.data();
          final dataConvert = data as Map;
          print('dataConvert: ${dataConvert.toString()}');
          userModel = UserModel.fromJson(dataConvert);
        } else {
          print('Tài liệu không tồn tại.');
          final http.Response responseData = await http.get(Uri.parse(userModel.imagePath));
          Uint8List uint8list = responseData.bodyBytes;
          var buffer = uint8list.buffer;
          ByteData byteData = ByteData.view(buffer);
          var tempDir = await getTemporaryDirectory();
          File file = await File('${tempDir.path}/img')
              .writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
          await HandleUser()
              .addInfoUser(userModel.fullName, userModel.email, userModel.id, '', '', '', '', imageFile: file);
        }

        // MyData.conversationMessages = await Handle().readSection(userModel.id);
        Get.offAll(HomePage());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'The account already exists with a different credential.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Error occurred while accessing credentials. Try again.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ));
        }
        signOutGoogle(context: context);
      } catch (e) {
        print('e.code: ${e}');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8.0),
              Text(
                'Error occurred using Google Sign-In. Try again.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        signOutGoogle(context: context);
      }
    }
    return user;
  }

  Future<void> signOutGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8.0),
            Text(
              'Error signing out. Try again.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ));
    }
  }
}
