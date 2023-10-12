import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourly/common/app_constants.dart';
import 'package:tourly/controllers/home_page_controller/home_page_controller.dart';

class HomePage extends StatelessWidget {
  HomePageController homepage = Get.find();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppConst.kPrimaryLightColor,
        body: homepage.chooseChildrenPage(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppConst.kPrimaryLightColor,
          selectedFontSize: 12,
          selectedIconTheme: const IconThemeData(color: AppConst.kButtonColor, size: 25),
          selectedItemColor: AppConst.kButtonColor,
          selectedLabelStyle: const TextStyle(fontFamily: 'Roboto'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto'),
          unselectedIconTheme: const IconThemeData(color: AppConst.kSubTextColor, size: 22),
          unselectedItemColor: AppConst.kSubTextColor,
          unselectedFontSize: 11,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(homepage.selectedIndex.value == 0 ? Icons.home : Icons.home_outlined), label: 'Trang chủ'),
            // BottomNavigationBarItem(
            //     icon: Icon(homepage.selectedIndex.value == 1 ? Icons.message : Icons.message_outlined),
            //     label: 'Chatbot'),
            BottomNavigationBarItem(
                icon: Icon(homepage.selectedIndex.value == 1 ? Icons.favorite : Icons.favorite_outline_outlined),
                label: 'Yêu thích'),
            BottomNavigationBarItem(
                icon: Icon(homepage.selectedIndex.value == 2 ? Icons.contact_support : Icons.contact_support_outlined),
                label: 'Trợ giúp'),
            BottomNavigationBarItem(
                icon: Icon(homepage.selectedIndex.value == 3 ? Icons.person : Icons.person_2_outlined),
                label: 'Tài khoản'),
          ],
          currentIndex: homepage.selectedIndex.value,
          onTap: (index) => homepage.setChildrenPageIndex(index),
        ),
      ),
    );
  }
}
