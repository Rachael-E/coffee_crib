import 'package:coffee_crib/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:coffee_crib/models/coffee_countries.dart'; // Import the CoffeeCountries model

class AboutPage extends StatelessWidget {
  final CoffeeFeature coffeeFeature; // Pass the selected CoffeeFeature object

  const AboutPage({Key? key, required this.coffeeFeature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(coffeeFeature.properties.admin), // Display the country name in the app bar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Country: ${coffeeFeature.properties.admin}'),
            Text(coffeeFeature.properties.description),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
