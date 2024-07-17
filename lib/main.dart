//
// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/services.dart' as services;

void main() {
  // Supply your apiKey using the --dart-define-from-file command line argument
  const apiKey = String.fromEnvironment('API_KEY');
  // Alternatively, replace the above line with the following and hard-code your apiKey here:
  // const apiKey = 'your_api_key_here';
  if (apiKey.isEmpty) {
    throw Exception('apiKey undefined');
  } else {
    ArcGISEnvironment.apiKey = apiKey;
  }

  // TODO remove services keyword when beta 2 is live
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
  String status = '';

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
          :  Scaffold(
              body: Center(
                  child: Text(status), // display if there is an error reading GeoJSON file
                ),
            ),
    );
  }

  void loadCoffeeCountries() async {
    const jsonFilePath = 'assets/FullCoffeeCountries_GEOJSON.geojson';
    try {
      final contents = await services.rootBundle.loadString(jsonFilePath);
      final coffeeCountries = coffeeCountriesDataFromJson(contents);
      coffeeCountries.features.sort(
        (a, b) => a.properties.admin.compareTo(b.properties.admin));

      coffeeCountries.features
          .map((feature) => _coffeeFeatures.add(feature))
          .toList();

      setState(() => _ready = true);

    } catch (error) {
      setState(() => status = error.toString());
      debugPrint('Error reading JSON file: $error');
    }
  }
}
