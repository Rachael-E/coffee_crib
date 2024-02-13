import 'package:coffee_crib/about_page.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/components/coffee_countries_grid.dart';
import 'package:coffee_crib/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List _items = [];
  CoffeeCountries? _coffeeCountries;

// Fetch content from the json file
  // Future<void> readJson() async {
  //   final String response =
  //       await rootBundle.loadString('assets/common_coffee_countries.geojson');
  //   final data = await json.decode(response);

  //   // CoffeeCountries coffeeCountries = welcomeFromJson('assets/common_coffee_countries.geojson');

  //   setState(() {
  //     _items = data["features"];
  //     // _coffeeCountries = coffeeCountries;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // readJson();
    // CoffeeCountries? _coffeeCountries;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home Page"),
      ),
      // body: ListView.builder(
      //         itemCount: _coffeeCountries!.features.length,
      //         itemBuilder: (context, index) {
      //           final feature = _coffeeCountries!.features[index];
      //           return ListTile(
      //             title: Text(feature.properties.admin),
      //             subtitle: Text(feature.properties.isoA3),
      //           );
      //         },
      // ),
            
      body: _coffeeCountries != null
      ? CoffeeCountriesGrid(
        items: _coffeeCountries!.features,
      )
      : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapPage()),
          );
        },
        child: const Icon(Icons.map_sharp, color: Colors.white),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadCoffeeCountries();

  }

  void loadCoffeeCountries() {

    CoffeeCountries coffeeCountries2;

        // Specify the path to your JSON file
    String jsonFilePath = 'assets/common_coffee_countries.geojson';

    // Read the JSON file
     rootBundle.loadString(jsonFilePath).then((String contents) {
          print('JSON Contents: $contents');

          coffeeCountries2 = welcomeFromJson(contents);

      // Parse the JSON data
      setState(() {

        _coffeeCountries ??= coffeeCountries2;
      });
    }).catchError((error) {
      print('Error reading JSON file: $error');
    });
  }

  }

