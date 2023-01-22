import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_demo/screen/searchCityData.dart';
import '../helper/db_helper.dart';
import '../provider/weather_provider.dart';
import '../utils/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TextEditingController cityNameController = TextEditingController();
  double kelvin = 273.15;
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  late GoogleMapController mapController;
  final Set<Marker> markers = {};

  _insert() async {
    Database? db = await DatabaseHelper.instance.database;
    Map<String, dynamic> row = {
      DatabaseHelper.columnName : cityNameController.text.toString().trim(),
    };
    await db?.insert(DatabaseHelper.table, row);
    debugPrint('${await db?.query(DatabaseHelper.table)}');
    cityNameController.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<WeatherProvider>(context,listen: false).getWeatherData(
        Provider.of<WeatherProvider>(context,listen: false).cityName);
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {

    bool showSearchData = MediaQuery.of(context).viewInsets.bottom !=0;

    return Scaffold(
      appBar : AppBar(
        backgroundColor: AppColor.appColor,
        title: const Text("Weather",),
        centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: cityNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'City Name',
                  ),

                  onChanged: (text) {},
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim().isEmpty) {
                      return 'Enter city name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10,),
                Visibility(
                  visible: showSearchData,
                    child: const MySearchCityName()
                ),
                const SizedBox(height: 20,),

                Consumer<WeatherProvider>(
                    builder: (context, snapshot,_) {
                    return GestureDetector(
                      onTap: (){
                       if(_formKey.currentState!.validate()){
                         snapshot.cityName = cityNameController.text.trim();
                         setState(() {});
                         snapshot.getWeatherData(
                             snapshot.cityName);
                         _insert();
                         FocusScope.of(context).unfocus();
                       }
                       },
                      child: Container(
                        width: double.infinity,
                        color: AppColor.appColor,
                        padding: const EdgeInsets.all(15),
                        child: const Center(child: Text('Search',style: TextStyle(color: AppColor.whiteColor),)),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 30,),

                FutureBuilder(
                  future: Provider.of<WeatherProvider>(context,listen: false).getWeatherData(
                      Provider.of<WeatherProvider>(context,listen: false).cityName),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.none ||
                        snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    } else if(snapshot.hasError){
                      return const Center(child: CircularProgressIndicator(),);
                    }
                    else{
                      return Consumer<WeatherProvider>(
                          builder: (context, snapshot,_) {
                            double? kel = snapshot.weatherModel?.main!.temp;
                            double celsious =  kel! - kelvin;
                            return Column(
                              children: [
                                Card(
                                  color: AppColor.appColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(DateTime.now().toString().substring(0,16),
                                          style: const TextStyle(color: AppColor.redColor),),
                                        const SizedBox(height: 10,),
                                        Text('${snapshot.weatherModel!.name}, ${snapshot.weatherModel!.sys!.country}',
                                          style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                        const SizedBox(height: 20,),
                                        Text('${celsious.round()}°C',style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                                        const SizedBox(height: 10,),
                                        Text('Feels like ${celsious.round()}°C. ${snapshot.weatherModel?.weather?[0].main}. ${snapshot.weatherModel?.base}',style: const TextStyle(fontSize: 16),),
                                        const SizedBox(height: 10,),

                                        Row(
                                          children: [
                                            const Icon(Icons.speed,size: 18,),
                                            const SizedBox(width: 5,),
                                            Text('${snapshot.weatherModel?.wind?.speed}',),
                                            const SizedBox(width: 20,),
                                            const Icon(Icons.rotate_90_degrees_ccw,size: 18,),
                                            const SizedBox(width: 5,),
                                            Text('${snapshot.weatherModel?.wind?.deg}',),
                                          ],
                                        ),
                                        const SizedBox(height: 10,),
                                        Row(
                                          children: [
                                            const Text('Humidity : '),
                                            const SizedBox(width: 5),
                                            Text('${snapshot.weatherModel?.main?.humidity}%'),
                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20,),

                                SizedBox(
                                  height: 200,
                                  child: GoogleMap(
                                    zoomGesturesEnabled: true,
                                    myLocationEnabled : true,
                                    compassEnabled: true,
                                    mapToolbarEnabled: true,
                                    tiltGesturesEnabled: true,
                                    myLocationButtonEnabled: true,
                                    indoorViewEnabled: true,
                                    trafficEnabled: true,
                                    onMapCreated: _onMapCreated,
                                    initialCameraPosition: CameraPosition(
                                        target: LatLng(snapshot.weatherModel!.coord!.lat!,snapshot.weatherModel!.coord!.lon!),
                                        zoom: 6
                                    ),
                                    markers: markers,
                                    onTap: (latLng){},
                                  ),
                                )
                              ],
                            );
                          }
                      );
                    }
                  }
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cityNameController.dispose();
    super.dispose();
  }
}
