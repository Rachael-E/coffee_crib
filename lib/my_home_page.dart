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

// Fetch content from the json file
  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/common_coffee_countries.geojson');
// final coffeeContries = welcomeFromJson(response);
    final data = await json.decode(response);
    setState(() {
      _items = data["features"];
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
      body: GridView.count(
        childAspectRatio: 5 / 3,
        crossAxisCount: 2,
        // padding: const EdgeInsets.all(20),
        children: List.generate(_items.length, (index) {
          return Center(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: const Color.fromARGB(255, 191, 92, 30),
              elevation: 10,
              child: InkWell(
                splashColor:
                    const Color.fromARGB(255, 221, 210, 199).withAlpha(30),
                onTap: () {
                  debugPrint(_items[index]["properties"]["Description"]);
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 100,
                    width: 150,
                    child: Column(
                      children: [
                        Text(
                          _items[index]["properties"]["ADMIN"],
                          // 'Item $_items[$index]. ',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const Icon(
                          Icons.coffee_rounded,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          // );
        }),
      ),
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
}
