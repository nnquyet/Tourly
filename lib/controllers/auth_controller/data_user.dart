import 'package:get/get.dart';

import '../../models/user_model.dart';

class DataUser {
  static Rx<UserModel> userModel = UserModel(
          fullName: '',
          email: '',
          id: '',
          imagePath: '',
          sex: '',
          phoneNumber: '',
          birthDay: '',
          address: '',
          loginWith: '')
      .obs;
}
