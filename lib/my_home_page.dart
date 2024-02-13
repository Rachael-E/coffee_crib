import 'package:coffee_crib/coffee_countries.dart';
import 'package:coffee_crib/components/coffee_countries_grid.dart';
import 'package:coffee_crib/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _items = [];
  CoffeeCountries? _coffeeCountries;

// Fetch content from the json file
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/common_coffee_countries.geojson');
    final data = await json.decode(response);

    // CoffeeCountries coffeeCountries = welcomeFromJson('assets/common_coffee_countries.geojson');

    setState(() {
      _items = data["features"];
      // _coffeeCountries = coffeeCountries;
    });
  }

  @override
  Widget build(BuildContext context) {
    readJson();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home Page"),
      ),
      body: CoffeeCountriesGrid(items: _items),
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

  }

  void loadCoffeeCountries() {

  }
}
