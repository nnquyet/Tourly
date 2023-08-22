import 'package:firebase_storage/firebase_storage.dart';

class Resource {
  String convertToSlug(String input) {
    // Chuyển chuỗi thành chữ thường
    input = input.toLowerCase();

    // Loại bỏ các ký tự không mong muốn (trong trường hợp này, dấu tiếng Việt)
    input = input
        .replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp('[đ]'), 'd')
        .replaceAll(RegExp('[\\W]'), ' '); // Loại bỏ các ký tự không phải chữ cái hoặc số

    // Loại bỏ khoảng trắng thừa và thay thế bằng dấu gạch ngang
    input = input.trim().replaceAll(RegExp(r'\s+'), '');

    return input;
  }

  Future<String> getImageUrl(String name) async {
    var storageRef = FirebaseStorage.instance.ref().child('address/${name}1.jpeg');

    try {
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (error) {
      print("Error getting image URL: $error");
      return ''; // Hoặc bạn có thể trả về một giá trị mặc định khác tùy theo ý muốn
    }
  }
}
