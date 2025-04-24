import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String apiKey = '';
const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

Future<void> fetchWeather(String city) async {
  final uri = Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric');

  final startTime = DateTime.now();

  try {
    final response = await HttpClient().getUrl(uri).then((req) => req.close());

    if (response.statusCode != 200) {
      throw HttpException('HTTP error: ${response.statusCode}');
    }

    final body = await response.transform(utf8.decoder).join();

    final data = jsonDecode(body) as Map<String, dynamic>;
    final weatherList = data['weather'] as List<dynamic>;
    final main = data['main'] as Map<String, dynamic>;
    final dt = data['dt'] as int;

    if (weatherList.isEmpty) {
      throw FormatException('Thiếu trường weather');
    }

    final description = weatherList[0]['description'];
    final temp = main['temp'];
    final humidity = main['humidity'];
    final pressure = main['pressure'];
    final updated = DateTime.fromMillisecondsSinceEpoch(dt * 1000).toLocal();

    print('\n--- Thời tiết ở $city ---');
    print('Mô tả        : $description');
    print('Nhiệt độ     : ${temp}°C');
    print('Độ ẩm        : ${humidity}%');
    print('Áp suất      : ${pressure} hPa');
    print('Cập nhật lúc : $updated');

  } on SocketException catch (e) {
    stderr.writeln(' Lỗi kết nối mạng: $e');
  } on HttpException catch (e) {
    stderr.writeln(' Lỗi HTTP: $e');
  } on FormatException catch (e) {
    stderr.writeln(' Lỗi phân tích JSON: $e');
  } catch (e) {
    stderr.writeln(' Có lỗi xảy ra: $e');
  }

  final duration = DateTime.now().difference(startTime);
  print('⏱ Thời gian phản hồi: ${duration.inMilliseconds} ms\n');
}

Future<void> main() async {
  stdout.write('Nhập tên thành phố: ');
  final city = stdin.readLineSync();

  if (city == null || city.trim().isEmpty) {
    print(' Vui lòng nhập tên thành phố hợp lệ.');
    return;
  }

  await fetchWeather(city.trim());
}
