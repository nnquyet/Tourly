import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:tourly/common/widgets/alert_dialog.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/controllers/auth_controller/hadle_user.dart';
import 'package:tourly/models/user_model.dart';
import 'package:tourly/views/home_page.dart';

class LoginController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final box = GetStorage();
  final formKeySignIn = GlobalKey<FormState>();
  final formKeyForgetPassword = GlobalKey<FormState>();

  //Login Phone
  RxString phoneNumber = "".obs;
  RxString verify = "".obs;
  RxString code = "".obs;
  late Rx<TextEditingController> countryController = TextEditingController().obs;

  //Login Email/Password
  Rx<bool> passwordVisible = false.obs;
  late Rx<bool> isRememberLogin;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    countryController.value.text = "+84";

    usernameController = TextEditingController(text: box.read("username"));
    passwordController = TextEditingController(text: box.read("password"));
    isRememberLogin = ((box.read("username") != null) && (box.read("password") != null)).obs;
  }

  void rememberLogin() {
    if (isRememberLogin.value) {
      box.write('username', usernameController.text);
      box.write('password', passwordController.text);
    } else {
      box.remove('username');
      box.remove('password');
    }
  }

  Future<void> signInWithPhoneNumber(BuildContext context) async {
    Get.dialog(const Center(child: CircularProgressIndicator()));
    box.remove('username');
    box.remove('password');
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verify.value, smsCode: code.value);

    // Sign the user in (or link) with the credential
    final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      DataUser.userModel.value = UserModel(
        fullName: 'Họ và tên',
        email: '',
        id: user.uid,
        imagePath: '',
        sex: '',
        phoneNumber: user.phoneNumber ?? '',
        birthDay: '',
        address: '',
        loginWith: 'phone',
      );
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(user?.phoneNumber);
    final documentSnapshot = await userRef.get();
    if (documentSnapshot.exists) {
      print('Tài liệu đã tồn tại!');
      final data = documentSnapshot.data();
      final dataConvert = data as Map;
      print('dataConvert: ${dataConvert.toString()}');
      DataUser.userModel.value = UserModel.fromJson(dataConvert as Map<String, dynamic>);
    } else {
      print('Tài liệu không tồn tại.');
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/${DataUser.userModel.value.id}.jpg');

      // Tải hình ảnh từ URL trực tiếp lên Firebase Storage
      final http.Response response =
          await http.get(Uri.parse('https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'));
      final Uint8List imageData = response.bodyBytes;
      final UploadTask uploadTask = storageReference.putData(imageData);
      await uploadTask;

      // Lấy đường dẫn tới tệp hình ảnh sau khi tải lên thành công
      final String downloadURL = await storageReference.getDownloadURL();
      DataUser.userModel.value.imagePath = downloadURL;

      await HandleUser().addInfoUser(DataUser.userModel.value);
    }
    box.write('user', DataUser.userModel.value.toJson());

    Get.back();
    Get.offAll(() => HomePage());
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    rememberLogin();

    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: usernameController.value.text, password: passwordController.value.text);

      User? user = firebaseAuth.currentUser;
      if (user != null) {
        bool isVerify = user.emailVerified;
        if (!isVerify) {
          Get.dialog(
            AlertDialogCustom(
                notification: "Vui lòng kiểm tra email để xác thực tài khoản",
                onPress: () {
                  Get.back();
                }),
          );
          return;
        }

        Get.dialog(const Center(child: CircularProgressIndicator()));

        DataUser.userModel.value = UserModel(
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          id: user.uid,
          imagePath: user.photoURL ?? '',
          sex: '',
          phoneNumber: '',
          birthDay: '',
          address: '',
          loginWith: 'email',
        );
      }
      final userRef = FirebaseFirestore.instance.collection('users').doc(user?.email);
      final documentSnapshot = await userRef.get();
      if (documentSnapshot.exists) {
        print('Tài liệu đã tồn tại!');
        final data = documentSnapshot.data();
        final dataConvert = data as Map;
        DataUser.userModel.value = UserModel.fromJson(dataConvert as Map<String, dynamic>);
      } else {
        print('Tài liệu không tồn tại.');
      }
      box.write('user', DataUser.userModel.value.toJson());

      // MyData.conversationMessages = await Handle().readSection(userCustom.id);
      Get.back();
      Get.offAll(() => HomePage());
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
    box.remove('username');
    box.remove('password');
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
        Get.dialog(const Center(child: CircularProgressIndicator()));

        final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
        user = userCredential.user;

        if (user != null) {
          DataUser.userModel.value = UserModel(
            fullName: user.displayName ?? '',
            email: user.email ?? '',
            id: user.uid,
            imagePath: user.photoURL ?? '',
            sex: '',
            phoneNumber: '',
            birthDay: '',
            address: '',
            loginWith: 'email',
          );
        }

        final userRef = FirebaseFirestore.instance.collection('users').doc(user?.email ?? '');
        final documentSnapshot = await userRef.get();
        if (documentSnapshot.exists) {
          print('Tài liệu đã tồn tại!');
          final data = documentSnapshot.data();
          final dataConvert = data as Map;
          print('dataConvert: ${dataConvert.toString()}');
          DataUser.userModel.value = UserModel.fromJson(dataConvert as Map<String, dynamic>);
        } else {
          print('Tài liệu không tồn tại.');
          final Reference storageReference =
              FirebaseStorage.instance.ref().child('images/${DataUser.userModel.value.id}.jpg');

          // Tải hình ảnh từ URL trực tiếp lên Firebase Storage
          final http.Response response = await http.get(Uri.parse(DataUser.userModel.value.imagePath));
          final Uint8List imageData = response.bodyBytes;
          final UploadTask uploadTask = storageReference.putData(imageData);
          await uploadTask;

          // Lấy đường dẫn tới tệp hình ảnh sau khi tải lên thành công
          final String downloadURL = await storageReference.getDownloadURL();
          DataUser.userModel.value.imagePath = downloadURL;

          await HandleUser().addInfoUser(DataUser.userModel.value);
        }
        box.write('user', DataUser.userModel.value.toJson());

        Get.offAll(() => HomePage());
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
        await signOut(context: context);
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
        await signOut(context: context);
      }
    }
    return user;
  }

  Future<void> signOut({required BuildContext context}) async {
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
