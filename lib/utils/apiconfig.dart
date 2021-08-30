import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:topheadlinesdemo/database/headlines_db_helper.dart';
import 'package:topheadlinesdemo/database/headlines_db_model.dart';
import 'package:topheadlinesdemo/news_headlines_page/headlines_page_model.dart';

class Apiconfig {
  static var _apiKey = "c8450db365394fe6a60774828754aa93";
  static Future<dynamic> getMethod(url, [header, params]) async {
    try {
      http.Response response = await http.get(
        url,
        headers: header,
      );

      final responseBody = json.decode(response.body);

      return responseBody;
    } on Error catch (e) {
      print('Error: $e');
    }
  }

  Future<List<HeadLineListDbModel>> getHeadlinesfromDb() {
    var data = HeadlineListDBHelper().getDbData();
    return data;
  }

  Future<TopHeadLineModel> topHeadlinesApi(_refresh) async {
    final dbData = getHeadlinesfromDb().then((value) async {
      if (value.length > 0 && _refresh == false) {
        /* if data available in db */
        return TopHeadLineModel.fromJson(json.decode(value.last.listdata));
      } else {
        /*Api call */
        final response = await getMethod(
            "https://newsapi.org/v2/top-headlines?country=us&apiKey=$_apiKey");

        TopHeadLineModel data = TopHeadLineModel.fromJson(response);

        return data;
      }
    });
    return dbData;
  }

/*search Api*/
  Future<TopHeadLineModel> searchTopHeadlinesApi(searchText) async {
    final response = await getMethod(
        "https://newsapi.org/v2/everything?q=$searchText&apiKey=$_apiKey");

    TopHeadLineModel data = TopHeadLineModel.fromJson(response);
    return data;
  }
}
