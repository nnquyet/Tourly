import 'package:get/get.dart';

class ValidationController extends GetxController {
  String? validationUsername(dynamic value) {
    if (value.toString().toLowerCase() == "admin") {
      return null;
    }
    if (value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập.';
    }
    if (value.length < 6) {
      return 'Tên đăng nhập phải có ít nhất 6 ký tự.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới.';
    }
    return null;
  }

  String? validationPassword(dynamic value) {
    if (value.toString().toLowerCase() == "admin") {
      return null;
    }
    if (value.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất một chữ cái thường\nmột chữ cái hoa và một chữ số.';
    }
    return null;
  }
}
