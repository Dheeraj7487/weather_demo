import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_demo/provider/weather_provider.dart';
import 'package:weather_demo/utils/app_color.dart';

class MySearchCityName extends StatefulWidget {
  const MySearchCityName({Key? key}) : super(key: key);

  @override
  _MySearchCityNameState createState() => _MySearchCityNameState();
}

class _MySearchCityNameState extends State<MySearchCityName> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<WeatherProvider>(context,listen: false).show();
    Provider.of<WeatherProvider>(context,listen: false).showData;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, snapshot,_) {
        return snapshot.showData.isEmpty ?
        const SizedBox() :
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 35.0,
            maxHeight: 160.0,
          ),
          child: ListView.separated(
            itemCount: snapshot.showData.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection : Axis.vertical,
            itemBuilder: (BuildContext context,index) {
              return GestureDetector(
                onTap: (){
                  snapshot.cityName = snapshot.showData[index]["cityName"];
                  snapshot.getWeatherData(snapshot.cityName);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 8.0,right: 8,bottom: 10,top: 10),
                  child: Text('${snapshot.showData[index]["cityName"]}' ,
                    style: const TextStyle(color: AppColor.blackColor,fontSize: 15,),),
                ),
              );
            }, separatorBuilder: (BuildContext context, int index) { return const Divider(); },
          ),
        );
      }
    );
  }

}