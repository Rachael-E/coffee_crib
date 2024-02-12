import 'package:coffee_crib/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home Page"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('We move under cover and we move as one'),
          const Text('Through the night, we have one shot to live another day'),
          const Text('We cannot let a stray gunshot give us away'),
          const Text('We will fight up close, seize the moment and stay in it'),
          const Text('It’s either that or meet the business end of a bayonet'),
          const Text('The code word is ‘Rochambeau,’ dig me?'),
          Text('Rochambeau!',
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: 2.0)),
        ],
      ),
    );
  }
}
