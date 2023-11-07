import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tourly/controllers/auth_controller/data_user.dart';
import 'package:tourly/controllers/home_page_controller/search_page_controller.dart';
import 'package:tourly/models/address_model.dart';
import 'package:tourly/models/comment_model.dart';
import 'package:tourly/views/chat_page/chat_item.dart';

import '../../models/user_model.dart';

class HandleUser {
  final search = Get.put(SearchPageController());
  int countWrite = 1;
  int countRead = 1;

  Future<void> addInfoUser(UserModel userModel) async {
    final DocumentReference<Map<String, dynamic>> userRef;
    if (userModel.loginWith == 'phone') {
      userRef = FirebaseFirestore.instance.collection('users').doc(userModel.phoneNumber);
    } else {
      userRef = FirebaseFirestore.instance.collection('users').doc(userModel.email);
    }

    // Lưu trữ thông tin người dùng vào Firestore
    await userRef.set({
      'fullName': userModel.fullName,
      'imagePath': userModel.imagePath,
      'id': userModel.id,
      'phoneNumber': userModel.phoneNumber,
      'email': userModel.email,
      'sex': userModel.sex,
      'birthDay': userModel.birthDay,
      'address': userModel.address,
      'loginWith': userModel.loginWith,
    });
  }

  // Lưu lịch sử cuộc hội thoại và các đoạn chat trong đó
  Future<void> addChat(String userChat, String botChat, String time) async {
    DocumentReference datas = FirebaseFirestore.instance.collection('chats').doc(DataUser.userModel.value.id);

    final dataSnapshot = await datas.get();
    final data = dataSnapshot.data();
    countWrite = dataSnapshot.exists ? (data as Map)['count'] + 1 : 1;

    if (dataSnapshot.exists) {
      await datas.update({
        '${countWrite}user': userChat,
        '${countWrite}bot': botChat,
        '${countWrite}time': time,
        'count': countWrite,
      });
    } else {
      await datas.set({
        '${countWrite}user': userChat,
        '${countWrite}bot': botChat,
        '${countWrite}time': time,
        'count': countWrite,
      });
    }
  }

  Future<List<ChatMessage>> readChat() async {
    DocumentReference datas = FirebaseFirestore.instance.collection('chats').doc(DataUser.userModel.value.id);

    List<ChatMessage> chatMessageReturn = [];

    final snapshot = await datas.get();
    if (snapshot.exists) {
      final Object? data = snapshot.data();
      int countRead = 1;
      (data as Map).forEach((key, value) {
        if ((data)['${countRead}user'] != null) {
          ChatMessage chatMessage = ChatMessage(
            text: (data)['${countRead}user'],
            isUser: true,
            isNewMessage: false,
            isDisplayTime: false,
            time: ((data)['${countRead}time']) ?? 'Monday, 2023 April 24, 12:00 AM',
          );
          ChatMessage chatMessageBot = ChatMessage(
            text: (data)['${countRead}bot'],
            isUser: false,
            isNewMessage: false,
            isDisplayTime: false,
            time: ((data)['${countRead}time']) ?? 'Monday, 2023 April 24, 12:00 AM',
          );
          chatMessageReturn.insert(0, chatMessage);
          chatMessageReturn.insert(0, chatMessageBot);
        }
        ++countRead;
      });
    }

    return chatMessageReturn;
  }

  Future<void> addComment(String comment, String id, String time) async {
    DocumentReference datas = FirebaseFirestore.instance.collection('comments').doc(id);

    final dataSnapshot = await datas.get();
    final data = dataSnapshot.data();
    countWrite = dataSnapshot.exists ? (data as Map)['count'] + 1 : 0;

    if (dataSnapshot.exists) {
      await datas.update({
        // '${countWrite}id': id,
        '${countWrite}fullName': DataUser.userModel.value.fullName,
        '${countWrite}imagePath': DataUser.userModel.value.imagePath,
        '${countWrite}time': time,
        '${countWrite}comment': comment,
        'count': countWrite,
      });
    } else {
      await datas.set({
        // '${countWrite}id': id,
        '${countWrite}fullName': DataUser.userModel.value.fullName,
        '${countWrite}imagePath': DataUser.userModel.value.imagePath,
        '${countWrite}comment': comment,
        '${countWrite}time': time,
        'count': countWrite,
      });
    }
  }

  Future<List<CommentModel>> readComment(String id) async {
    DocumentReference datas = FirebaseFirestore.instance.collection('comments').doc(id);

    List<CommentModel> commentListReturn = [];

    final snapshot = await datas.get();
    if (snapshot.exists) {
      final Object? data = snapshot.data();
      int countRead = 0;
      (data as Map).forEach((key, value) {
        if ((data)['${countRead}comment'] != null) {
          CommentModel comment = CommentModel(
            // id: id,
            fullName: (data)['${countRead}fullName'],
            imagePath: (data)['${countRead}imagePath'],
            comment: (data)['${countRead}comment'],
            time: (data)['${countRead}time'],
          );

          commentListReturn.insert(0, comment);
        }
        ++countRead;
      });
    }
    return commentListReturn;
  }

  // Future<void> getDataFromFirestore() async {
  //   // Lấy tham chiếu đến bộ sưu tập "cities"
  //   final citiesCollection = FirebaseFirestore.instance.collection('cities');
  //
  //   // Lấy tất cả các tài liệu trong bộ sưu tập "cities"
  //   final querySnapshot = await citiesCollection.get();
  //
  //   for (QueryDocumentSnapshot cityDocument in querySnapshot.docs) {
  //     // Lấy tên của thành phố
  //     final cityName = cityDocument.id;
  //
  //     // Lấy tham chiếu đến bộ sưu tập "listcities" trong thành phố hiện tại
  //     final listCitiesCollection = citiesCollection.doc(cityName).collection('locations');
  //
  //     // Lấy tất cả các địa điểm trong bộ sưu tập "city" cho thành phố hiện tại
  //     final listLocationsSnapshot = await listCitiesCollection.get();
  //
  //     for (QueryDocumentSnapshot locationsDocument in listLocationsSnapshot.docs) {
  //       Map<String, dynamic>? data = locationsDocument.data() as Map<String, dynamic>?;
  //       if (data != null) {
  //         AddressModel addressModel = AddressModel.fromJson(data, locationsDocument.id);
  //         search.addressList.add(addressModel);
  //       }
  //     }
  //   }
  //   search.filterAddressList.addAll(search.addressList);
  // }

  Future<void> getLocationsFromFirestore() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('locations').get();

    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        AddressModel addressModel = AddressModel.fromJson(data, documentSnapshot.id);
        search.addressList.add(addressModel);
      }
    }
    search.filterAddressList.addAll(search.addressList);
  }

  Future<void> favoriteLocation(String id) async {
    DataUser.idFavoritesList.insert(0, id);
    handleFavorites();
    getFavoritesFromFirestore();

    DocumentReference datas = FirebaseFirestore.instance.collection('locations').doc(id);
    final dataSnapshot = await datas.get();

    final data = dataSnapshot.data();
    int like = dataSnapshot.exists ? (data as Map)['likes'] + 1 : 1;
    if (dataSnapshot.exists) {
      await datas.update({
        'likes': like,
      });
    } else {
      await datas.set({
        'likes': like,
      });
    }
  }

  Future<void> unfavoriteLocation(String id) async {
    DataUser.idFavoritesList.remove(id);
    handleFavorites();
    getFavoritesFromFirestore();

    DocumentReference datas = FirebaseFirestore.instance.collection('locations').doc(id);
    final dataSnapshot = await datas.get();

    final data = dataSnapshot.data();
    int like = dataSnapshot.exists ? (data as Map)['likes'] - 1 : 0;
    if (dataSnapshot.exists) {
      await datas.update({
        'likes': like,
      });
    } else {
      await datas.set({
        'likes': like,
      });
    }
  }

  Future<void> handleFavorites() async {
    DocumentReference datas = FirebaseFirestore.instance.collection('favorites').doc(DataUser.userModel.value.id);
    final dataSnapshot = await datas.get();

    if (dataSnapshot.exists) {
      await datas.update({
        'list': DataUser.idFavoritesList,
      });
    } else {
      await datas.set({
        'list': DataUser.idFavoritesList,
      });
    }
  }

  Future<void> getIdFavoritesFromFirestore() async {
    DataUser.idFavoritesList.clear();
    DataUser.favoritesList.clear();
    DocumentReference datas = FirebaseFirestore.instance.collection('favorites').doc(DataUser.userModel.value.id);
    final dataSnapshot = await datas.get();

    if (dataSnapshot.exists) {
      var data = dataSnapshot.data() as Map<String, dynamic>;
      var favorites = data['list'] as List<dynamic>;
      DataUser.idFavoritesList.addAll(favorites.map((item) => item.toString()));
    } else {
      print('Tài liệu không tồn tại.');
    }
    await getFavoritesFromFirestore();
  }

  Future<void> getFavoritesFromFirestore() async {
    DataUser.favoritesList.clear();

    for (int i = 0; i < DataUser.idFavoritesList.length; i++) {
      final dataSnapshot =
          await FirebaseFirestore.instance.collection('locations').doc(DataUser.idFavoritesList[i]).get();
      Map<String, dynamic>? data = dataSnapshot.data();

      if (data != null) {
        AddressModel addressModel = AddressModel.fromJson(data, DataUser.idFavoritesList[i]);
        DataUser.favoritesList.add(addressModel);
      }
    }
  }

  Future<void> increaseViews(AddressModel addressModel) async {
    DocumentReference datas = FirebaseFirestore.instance.collection('locations').doc(addressModel.id);
    final dataSnapshot = await datas.get();

    final data = dataSnapshot.data();
    addressModel.views = dataSnapshot.exists ? (data as Map)['views'] + 1 : 1;
    if (dataSnapshot.exists) {
      await datas.update({
        'views': addressModel.views,
      });
    } else {
      await datas.set({
        'views': addressModel.views,
      });
    }
  }

  String handleUserInput(String userInput) {
    if (userInput.toLowerCase().contains("xin chào")) {
      return ("Xin chào! Tôi là chatbot, bạn cần tôi giúp gì?");
    } else if (userInput.toLowerCase().contains("tạm biệt")) {
      return ("Tạm biệt! Hãy quay lại nếu bạn cần sự trợ giúp của tôi.");
    } else if (userInput.toLowerCase().contains("cảm ơn")) {
      return ("Không có gì! Hãy nói với tôi nếu bạn cần sự trợ giúp.");
    } else if (userInput.toLowerCase().contains("hôm nay là ngày mấy")) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy').format(now);
      return ("Hôm nay là ngày $formattedDate.");
    } else if (userInput.toLowerCase().contains("tổng")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 3) {
        return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tổng 2 và 3'.");
      } else {
        try {
          int num1 = int.parse(words[2]);
          int num2 = int.parse(words[4]);
          int sum = num1 + num2;
          return ("Tổng của $num1 và $num2 là $sum.");
        } on FormatException {
          return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tổng 2 và 3'.");
        }
      }
    } else if (userInput.toLowerCase().contains("tính hiệu")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 3) {
        return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính hiệu 5 trừ đi 3'.");
      } else {
        try {
          int num1 = int.parse(words[2]);
          int num2 = int.parse(words[4]);
          int diff = num1 - num2;
          return ("Hiệu của $num1 trừ đi $num2 là $diff.");
        } on FormatException {
          return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính hiệu 5 trừ đi 3'.");
        }
      }
    } else if (userInput.toLowerCase().contains("tính tích")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 3) {
        return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tích 2 và 3'.");
      } else {
        try {
          int num1 = int.parse(words[2]);
          int num2 = int.parse(words[4]);
          int product = num1 * num2;
          return ("Tích của $num1 và $num2 là $product.");
        } on FormatException {
          return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Tính tích 5 nhân 3'.");
        }
      }
    } else if (userInput.toLowerCase().contains("đổi mật khẩu")) {
      return ("Để đổi mật khẩu, vui lòng truy cập trang đổi mật khẩu trên ứng dụng của chúng tôi.");
    } else if (userInput.toLowerCase().contains("cập nhật thông tin")) {
      return ("Để cập nhật thông tin, vui lòng truy cập trang cập nhật thông tin trên ứng dụng của chúng tôi.");
    } else if (userInput.toLowerCase().contains("tìm kiếm")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 2) {
        return ("Vui lòng nhập từ khóa tìm kiếm. Ví dụ: 'Tìm kiếm sản phẩm A'.");
      } else {
        String keyword = userInput.substring(18).trim();
        return ("Đang tìm kiếm với từ khóa: $keyword");
      }
    } else if (userInput.toLowerCase().contains("đặt hàng")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 2) {
        return ("Vui lòng nhập thông tin đặt hàng. Ví dụ: 'Đặt hàng sản phẩm A số lượng 2'.");
      } else {
        try {
          String product = words[2];
          int quantity = int.parse(words[4]);
          return ("Đã đặt hàng $quantity $product.");
        } on FormatException {
          return ("Vui lòng nhập đúng cú pháp. Ví dụ: 'Đặt hàng sản phẩm A số lượng 2'.");
        }
      }
    } else if (userInput.toLowerCase().contains("hướng dẫn sử dụng")) {
      return ("Vui lòng truy cập trang hướng dẫn sử dụng trên ứng dụng của chúng tôi để biết thêm chi tiết.");
    } else if (userInput.toLowerCase().contains("đánh giá sản phẩm")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 2) {
        return ("Vui lòng nhập tên sản phẩm để đánh giá. Ví dụ: 'Đánh giá sản phẩm A'.");
      } else {
        String product = userInput.substring(17).trim();
        return ("Vui lòng truy cập trang đánh giá sản phẩm $product trên ứng dụng của chúng tôi.");
      }
    } else if (userInput.toLowerCase().contains("thông tin sản phẩm")) {
      List<String> words = userInput.split(' ');
      if (words.length <= 2) {
        return ("Vui lòng nhập tên sản phẩm để xem thông tin chi tiết. Ví dụ: 'Thông tin sản phẩm A'.");
      } else {
        String product = userInput.substring(19).trim();
        return ("Đang tìm kiếm thông tin sản phẩm $product.");
      }
    } else {
      return ("Xin lỗi, tôi không hiểu câu hỏi của bạn. Hãy thử lại với câu hỏi khác.");
    }
  }
}
