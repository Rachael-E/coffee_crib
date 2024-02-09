import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:arcgis_maps/arcgis_maps.dart';

void main() {
  ArcGISEnvironment.apiKey =
      '';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  int _counter = 1;

  void getNext() {
    _counter++;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List _items = [];

// Fetch content from the json file
Future<void> readJson() async {
final String response = await rootBundle.loadString('assets/common_coffee_countries.geojson');
// final coffeeContries = welcomeFromJson(response);
final data = await json.decode(response);
setState(() {
  _items = data["features"];
});
}
    
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var number = appState._counter;

    readJson();

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home Page"),
      ),
      body: GridView.count(
        childAspectRatio: 5/3,

        crossAxisCount: 2,
        // padding: const EdgeInsets.all(20),
        children: List.generate(_items.length, (index) {
    
          return Center(
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: theme.colorScheme.inversePrimary,
              elevation: 10,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
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
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center ,
                        
                        ),
                        const Icon(Icons.coffee_rounded)

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

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapViewController = ArcGISMapView.createController();
  final _map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISChartedTerritory);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Map Page'),
      ),
      body: ArcGISMapView(
        controllerProvider: () => _mapViewController,
        onMapViewReady: onMapViewReady,
      ),
      floatingActionButton: FloatingActionButton(

        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          appState.getNext();
              print(_map.hashCode);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        },
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  void onMapViewReady() async {
    _mapViewController.arcGISMap = _map;
  }
}
