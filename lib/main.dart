import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/services.dart' as services;

void main() async {
  // Supply your apiKey using the --dart-define-from-file command line argument
  const apiKey = String.fromEnvironment('API_KEY');
  // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // const apiKey = 'your_api_key_here';
  if (apiKey.isEmpty) {
    throw Exception('apiKey undefined');
  } else {
    ArcGISEnvironment.apiKey = apiKey;
  }
  services.SystemChrome.setPreferredOrientations([
    services.DeviceOrientation.portraitDown,
    services.DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _coffeeFeatures = <CoffeeFeature>[];
  var _ready = false;

  @override
  void initState() {
    loadCoffeeCountries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Crib',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: _ready
          ? MyHomePage(coffeeFeatures: _coffeeFeatures)
          : const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  void loadCoffeeCountries() async {
    const jsonFilePath = 'assets/FullCoffeeCountries_GEOJSON.geojson';

    try {
      final contents = await services.rootBundle.loadString(jsonFilePath);
      final coffeeCountries = coffeeCountriesDataFromJson(contents);

      coffeeCountries.features.sort(
        (a, b) => a.properties.admin.compareTo(b.properties.admin),
      );

      coffeeCountries.features
          .map((feature) => _coffeeFeatures.add(feature))
          .toList();

      setState(() {
        _ready = true;
      });
    } catch (error) {
      debugPrint('Error reading JSON file: $error');
    }
  }
}
