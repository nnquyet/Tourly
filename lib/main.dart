import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourly/common/all_bindings.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/models/user_model.dart';
import 'package:tourly/views/home_page.dart';
import 'package:tourly/views/welcome_page/greeting_screen.dart';
import 'package:tourly/views/welcome_page/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();

  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AllBindings allBindings = AllBindings();
    allBindings.dependencies();
    final box = GetStorage();
    final checkFirstLogin = box.read('accessed_application') ?? false;
    final storedUser = box.read('user');
    if (storedUser != null) {
      DataUser.userModel.value = UserModel.fromJson(storedUser);
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: storedUser == null
          ? !checkFirstLogin
              ? const Greeting()
              : Welcome()
          : HomePage(),
    );
  }
}
