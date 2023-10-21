import 'package:get/get.dart';
import 'package:tourly/models/address_model.dart';
import 'package:tourly/models/user_model.dart';

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

  static RxList<String> idFavoritesList = <String>[].obs;
  static RxList<AddressModel> favoritesList = <AddressModel>[].obs;
}
