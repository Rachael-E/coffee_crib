import 'package:coffee_crib/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:coffee_crib/env/env.dart';
import 'package:arcgis_maps/arcgis_maps.dart';


void main() {
  ArcGISEnvironment.apiKey = Env.apiKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

      return MaterialApp(
        title: 'Coffee Crib',

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      );
  }
}

