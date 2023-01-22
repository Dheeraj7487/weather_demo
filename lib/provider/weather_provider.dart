import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_demo/model/weather_model.dart';

import '../helper/db_helper.dart';

class WeatherProvider extends ChangeNotifier{
  WeatherModel? weatherModel;

  DatabaseHelper dbHelper = DatabaseHelper.instance;
  String cityName = 'Ahmedabad';

  get getCityName{
    notifyListeners();
    return cityName;
  }

  var showData = [];
  void show()  async{
    final fetchData  = await dbHelper.fetchCityNameData();
      showData = fetchData;
      notifyListeners();
  }

  Future<WeatherModel?> getWeatherData(String cityName) async {
    final String url = 'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=3ca68f37e06821d2c23a0659659e2fc1';
    try {
      final response =await http.get(Uri.parse(url),);
      if (response.statusCode == 200) {
        weatherModel = WeatherModel.fromJson(json.decode(response.body));
        //print("ID '${weatherModel?.id}'");
        notifyListeners();
        return jsonDecode(response.body);
      }
      else{
        return weatherModel;
      }
    } catch(e) {
      print(e);
    }
    notifyListeners();
  }
}