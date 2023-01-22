import 'package:provider/provider.dart';
import 'package:weather_demo/provider/weather_provider.dart';
import 'package:weather_demo/screen/home_screen.dart';
import 'package:flutter/material.dart';

void main() async{
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>(create: (_) => WeatherProvider()),
          ],
          child: const MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

