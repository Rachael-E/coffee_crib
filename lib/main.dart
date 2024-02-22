import 'package:coffee_crib/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:coffee_crib/env/env.dart';
import 'package:provider/provider.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:coffee_crib/map_model.dart';


void main() {
  ArcGISEnvironment.apiKey = Env.apiKey;

  runApp(
    ChangeNotifierProvider(
      create: (context) => MapModel(),
      child: const MyApp(),
    ),
  );
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      );
  }
}

