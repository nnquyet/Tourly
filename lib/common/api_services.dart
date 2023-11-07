import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tourly/controllers/home_page_controller/setting_controller.dart';

List<String> myList = [];

var random = Random();
int index = random.nextInt(myList.length);
String apiKeyUnsplash = myList[index];

class ApiChatBotServices {
  final SettingController setting = Get.find();
  static String baseUrl_3 = 'https://api.openai.com/v1/completions';
  static String baseUrl_3_5 = 'https://api.openai.com/v1/chat/completions';
  static String baseUrl_image = 'https://api.openai.com/v1/images/generations';

  static String apiGoogle = 'AIzaSyAbyi1_Sshpx4IuarznLDiLsYV6SYUrpbU';
  static String searchEngineGoogle = '631918e93d104e973';

  Future<String> sendMessage(List<String> message) async {
    String? result;
    result = await model3_5(message);
    return result;
  }

  Future<String> model3_5(List<String> message) async {
    var length = message.length;
    var res = await http.post(Uri.parse(baseUrl_3_5),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${setting.keyAPIController.value.text == '' ? setting.randomKeyAPI() : setting.keyAPIController.value.text}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": length > 4 ? message[4] : 'Xin chào'},
            {"role": "assistant", "content": length > 3 ? message[3] : 'Chào bạn, tôi có thể giúp gì?'},
            {"role": "user", "content": length > 2 ? message[2] : 'Bạn khỏe không?'},
            {
              "role": "assistant",
              "content": length > 1 ? message[1] : 'Tôi khỏe, cảm ơn bạn, bạn cần tôi giúp gì không?'
            },
            {"role": "user", "content": message[0]}
          ],
          'temperature': 0,
          'max_tokens': 400,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

  Future<String> model3(List<String> message) async {
    var res = await http.post(Uri.parse(baseUrl_3),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${setting.keyAPIController.value.text == '' ? setting.randomKeyAPI() : setting.keyAPIController.value.text}',
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': message[0],
          'temperature': 0,
          'max_tokens': 400,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['text'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

  Future<String> translate(String? question, String? message) async {
    var res = await http.post(Uri.parse(baseUrl_3_5),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${setting.keyAPIController.value.text == '' ? setting.randomKeyAPI() : setting.keyAPIController.value.text}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Take the 3 main keywords from the following passage: \'$question $message\', and translate those keywords into English according to the format: \"[keywordInEnglish]: [keywordInVietNamese]\""
              // Take 1 main keyword in the following sentence and then translate it into English and divide it with a \':\'
              // Take the 3 main keywords in the following sentence and translate them into English:
            }
          ],
          'temperature': 0,
          'max_tokens': 80,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

  Future<List<String>> generateImage(String text) async {
    List<String> result = [];
    var res = await http.post(Uri.parse(baseUrl_image),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${setting.keyAPIController.value.text == '' ? setting.randomKeyAPI() : setting.keyAPIController.value.text}',
        },
        body: jsonEncode({
          "prompt": text,
          "n": 4,
          "size": "256x256",
        }));

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body.toString());
      result.add(data['data'][0]['url'].toString());
      result.add(data['data'][1]['url'].toString());
      result.add(data['data'][2]['url'].toString());
      result.add(data['data'][3]['url'].toString());
      return result;
    } else {
      print("Failed to fetch image ${res.statusCode}");
      return [];
    }
  }

  Future<String> buildQuestions(String? message) async {
    var res = await http.post(Uri.parse(baseUrl_3_5),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${setting.keyAPIController.value.text == '' ? setting.randomKeyAPI() : setting.keyAPIController.value.text}',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": "Hãy viết cho tôi 4 câu hỏi về chủ đề trong đoạn văn sau: $message"}
          ],
          'temperature': 0,
          'max_tokens': 300,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));
    if (res.statusCode == 200) {
      var data = jsonDecode(utf8.decode(res.bodyBytes));
      var msg = data['choices'][0]['message']['content'];
      return msg;
    } else {
      print('Failed to fetch data: ${res.statusCode}');
      return '';
    }
  }

  Future<String> getAudioUrl(String text) async {
    String voice = setting.selectedVoice.value;
    switch (voice) {
      case 'Linh San':
        voice = 'linhsan';
        break;
      case 'Ban Mai':
        voice = 'banmai';
        break;
      case 'Lan Nhi':
        voice = 'lannhi';
        break;
      case 'Lê Minh':
        voice = 'leminh';
        break;
      case 'Mỹ An':
        voice = 'myan';
        break;
      case 'Thu Minh':
        voice = 'thuminh';
        break;
      case 'Gia Huy':
        voice = 'giahuy';
        break;
    }
    String apiKey = 'l5b50ULc9kehWQZ5vbAFyMI5o9Sn6UAB';
    String speed = '0';
    final response = await http.post(
      Uri.parse('https://api.fpt.ai/hmi/tts/v5'),
      headers: {
        'api_key': apiKey,
        'voice': voice,
        'speed': speed,
      },
      body: text,
    );

    if (response.statusCode == 200) {
      final data = response.body;
      print(data);
      Map<String, dynamic> dataConvert = jsonDecode(data);
      final audioUrl = dataConvert['async'];
      print(audioUrl);
      return audioUrl;
    } else {
      throw Exception('Failed to load audio ${response.statusCode}');
    }
  }

  static Future<String> getImageUrl(String query) async {
    final response =
        await http.get(Uri.parse('https://api.unsplash.com/photos/random?query=$query&client_id=$apiKeyUnsplash'));
    final data = jsonDecode(response.body);
    final imageUrl = data['urls']['small'];
    return imageUrl;
  }

  static Future<List<String>> getImagesFromGG(String query) async {
    final apiKey = apiGoogle;
    final searchEngineId = searchEngineGoogle;
    final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$searchEngineId&key=$apiKey&searchType=image&num=4');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<String> imageUrls = [];
      for (var item in data['items']) {
        imageUrls.add(item['link']);
      }
      print('imageUrls: $imageUrls');
      return imageUrls;
    } else {
      throw Exception('Failed to load images');
    }
  }

  static Future<String> modelData(String question, String context) async {
    final url = Uri.parse('http://117.6.135.148:8888/returnanswer');
    // Tạo dữ liệu JSON từ đầu vào
    final inputData = {"question": question, "context": context};
    try {
      // Gửi yêu cầu POST với dữ liệu JSON
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(inputData),
      );
      if (response.statusCode == 200) {
        // Phân tích chuỗi JSON thành đối tượng Map
        final jsonResponse = json.decode(response.body);
        // Sử dụng dữ liệu từ JSON

        final data = jsonResponse['answer'][0]['answer'];

        // final errorCode = jsonResponse['errorCode'];
        // final errorMessage = jsonResponse['errorMessage'];
        print('Data: $data');

        return data;
      } else {
        print('Request failed with status: ${response.statusCode}');
        return 'The server is not ready!';
      }
    } catch (error) {
      print('Error: $error');
      return 'An error occurred while calling the API!';
    }
  }

  static const String apiKeyGoogleMap = 'AIzaSyCUu0k9yrpDRLLozquTbqLFTneMdBM9OQA';

  static Future<String> getDirections(String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKeyGoogleMap';
    String step = '';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      final Direction direction = Direction.fromJson(decodedData);
      // List<String> steps = direction.steps;

      print('step: ${direction.toString()}');
      // step =
      //     '- StartAddress :${direction.startAddress}\n- EndAddress: ${direction.endAddress}\n- Distance: ${direction.distance}\n- Duration: ${direction.duration}\n- Step: \n';
      step = parse(direction.toString()).documentElement!.text;
      print('step: $step');

      return step;
    } else {
      return 'Không xác định được địa điểm của bạn';
    }
  }

  static Future<String> fetchWeatherData(String city) async {
    String apiKey = "6011f56b8259dc5bafd3cc279e8f46da";
    String url = "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=vi";
    String dataWeather;

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Xử lý dữ liệu theo nhu cầu của bạn
        dataWeather =
            'Nhiệt độ: ${data['main']['temp']}°C\nĐộ ẩm: ${data['main']['humidity']}%\nTrạng thái: ${data['weather'][0]['description']}';
        print('Thời tiết hiện tại\n$dataWeather');
        return dataWeather = '\nThời tiết hiện tại:\n$dataWeather';
      } else {
        print('Lỗi ${response.statusCode}');
        return 'Không tìm thấy địa điểm của bạn';
      }
    } catch (e) {
      print('Lỗi $e');
      return 'Lỗi $e';
    }
  }

  static Future<String> fetchWeatherForecast(String city) async {
    List<WeatherForecast> forecastList = [];
    String dataWeather = '\nDự báo thời tiết 5 ngày tới:';
    String apiKey = "6011f56b8259dc5bafd3cc279e8f46da";
    String url = "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=vi";

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> forecastData = data['list'];

        DateTime dateTime = DateTime.now();
        String currentDate = DateFormat('yyyy-MM-dd').format(dateTime);
        double minTemperature = double.infinity;
        double maxTemperature = double.negativeInfinity;

        for (var item in forecastData) {
          String timestamp = item['dt_txt'];
          timestamp = timestamp.split(' ')[0];
          print(timestamp.split(' ')[0]);
          if (timestamp != currentDate) {
            String description = item['weather'][0]['description'];

            WeatherForecast forecast = WeatherForecast(
              date: currentDate,
              description: description,
              temperatureMin: minTemperature,
              temperatureMax: maxTemperature,
            );

            forecastList.add(forecast);

            currentDate = timestamp;
            minTemperature = double.infinity;
            maxTemperature = double.negativeInfinity;
          }

          double temperature = item['main']['temp'].toDouble();
          if (temperature < minTemperature) {
            minTemperature = temperature;
          }
          if (temperature > maxTemperature) {
            maxTemperature = temperature;
          }
        }

        for (var item in forecastList) {
          DateTime dateTime = DateTime.parse(item.date);
          String formattedDate = DateFormat('EEEE, MMMM dd').format(dateTime);
          String temperatureRange = "${item.temperatureMax.round()}°C/${item.temperatureMin.round()}°C";
          String weather5Days = "- $formattedDate\n${item.description} - $temperatureRange";
          dataWeather += '\n' + weather5Days;
        }
        return dataWeather;
      } else {
        print('Error ${response.statusCode}');
        return 'Không tìm thấy địa điểm của bạn';
      }
    } catch (e) {
      print('Error $e');
      return 'Error $e';
    }
  }
}

class WeatherForecast {
  final String date;
  final String description;
  double temperatureMin;
  double temperatureMax;

  WeatherForecast({
    required this.date,
    required this.description,
    required this.temperatureMin,
    required this.temperatureMax,
  });
}

class Direction {
  final String startAddress;
  final String endAddress;
  final String distance;
  final String duration;
  final List<String> steps;

  Direction({
    required this.startAddress,
    required this.endAddress,
    required this.distance,
    required this.duration,
    required this.steps,
  });

  factory Direction.fromJson(Map<String, dynamic> json) {
    final legs = json['routes'][0]['legs'][0];

    return Direction(
      startAddress: legs['start_address'],
      endAddress: legs['end_address'],
      distance: legs['distance']['text'],
      duration: legs['duration']['text'],
      steps: List<String>.from(legs['steps'].map((step) => step['html_instructions'])),
    );
  }

  @override
  String toString() {
    final StringBuilder = StringBuffer();
    StringBuilder.writeln('Start Address: $startAddress');
    StringBuilder.writeln('End Address: $endAddress');
    StringBuilder.writeln('Distance: $distance');
    StringBuilder.writeln('Duration: $duration');
    StringBuilder.writeln('Steps:');
    for (var i = 0; i < steps.length; i++) {
      StringBuilder.writeln('${i + 1}. ${steps[i]}');
    }
    return StringBuilder.toString();
  }
}
