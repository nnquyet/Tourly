import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourly/common/all_bindings.dart';
import 'package:tourly/controllers/home_page_controller/home_page_controller.dart';
import 'package:tourly/views/auth_page/login_page.dart';
import 'package:tourly/views/home_page.dart';
import 'package:tourly/views/search_page/search_page.dart';
import 'package:tourly/views/welcome_page/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AllBindings allBindings = AllBindings();
  allBindings.dependencies();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      // home: WelcomeScreen(),
      home: HomePage(),
    );
  }
}
