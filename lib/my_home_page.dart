import 'package:coffee_crib/map_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/components/coffee_countries_grid.dart';
import 'package:coffee_crib/map_page.dart';
import 'package:provider/provider.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CoffeeCountries? _coffeeCountries;
  final GlobalKey<MapPageState> mapPageKey = GlobalKey<MapPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home Page"),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              child: _coffeeCountries != null
                  ? GridView.count(
                      childAspectRatio: 6 / 3,
                      crossAxisCount: 4,
                      padding: EdgeInsets.zero,
                      children: List.generate(_coffeeCountries!.features.length,
                          (index) {
                        var coffeeCountry = _coffeeCountries!.features[index];
                        drawCoffeeCountriesPolygons(coffeeCountry);
                        // _coffeeCountries!.features.forEach((element) => drawCoffeeCountriesPolygons(element));
                        return Center(
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            color: const Color.fromARGB(255, 191, 92, 30),
                            elevation: 10,
                            child: InkWell(
                              splashColor:
                                  const Color.fromARGB(255, 221, 210, 199)
                                      .withAlpha(30),
                              onTap: () {
                                drawCoffeeCountriesPolygons(coffeeCountry);
                                
                                // debugPrint(coffeeCountry.geometry.coordinates[0].toString());
                                // mapPageKey.currentState?.changeViewpoint(0, 0);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Center(
                                  child: SizedBox(
                                    child: Text(
                                      coffeeCountry.properties.admin,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Expanded(
            flex: 7,
            child: MapPage(key: mapPageKey),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadCoffeeCountries();
  }

  void loadCoffeeCountries() {
    CoffeeCountries coffeeCountriesFromJson;

    String jsonFilePath = 'assets/common_coffee_countries.geojson';

    // Read the JSON file
    rootBundle.loadString(jsonFilePath).then((String contents) {
      coffeeCountriesFromJson = welcomeFromJson(contents);

      // Parse the JSON data
      setState(() {
        _coffeeCountries ??= coffeeCountriesFromJson;
        print('set state');
      });
    }).catchError((error) {
      print('Error reading JSON file: $error');
    });
  }

  void drawCoffeeCountriesPolygons(CoffeeFeature feature) {    
    var polygonBuilder =
        PolygonBuilder.fromSpatialReference(SpatialReference.wgs84());
    var polygonBuilderFromParts =
        PolygonBuilder.fromSpatialReference(SpatialReference.wgs84());

    var coffeeFeatureCoordinates = feature.geometry.coordinates;

    if (coffeeFeatureCoordinates.length == 1) { // if country is a single part polygon
      for (var coordinate in coffeeFeatureCoordinates[0]) {
        var lat = coordinate[0];
        var long = coordinate[1];
        polygonBuilder.addPoint(
          ArcGISPoint(
            x: lat,
            y: long,
            spatialReference: SpatialReference.wgs84(),
          ),
        );
      }
      drawAndNavigate(polygonBuilder);
    } else { // if country is a multipart
      for (var part in coffeeFeatureCoordinates) {
        var mutablePart =
            MutablePart.withSpatialReference(SpatialReference.wgs84());
        for (var coordinates in part) {
          for (var coordinate in coordinates) {
            var lat = coordinate[0];
            var long = coordinate[1];
            mutablePart.addPoint(
              ArcGISPoint(
                x: lat,
                y: long,
                spatialReference: SpatialReference.wgs84(),
              ),
            );
          }
        }
        polygonBuilderFromParts.parts.addPart(mutablePart: mutablePart);
      }
      drawAndNavigate(polygonBuilderFromParts);
    }
  }

  void drawAndNavigate(PolygonBuilder polygonBuilder) {
    var polygon = polygonBuilder.toGeometry();
    if (mapPageKey.currentState?.graphicsOverlay.graphics.length != _coffeeCountries!.features.length) {
    mapPageKey.currentState?.addToGraphicsOverlay(polygon);
    }
    mapPageKey.currentState?.changeViewpoint(polygon.extent);
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String selectedPage = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 147, 226, 175),
          ),
          child: Text(
            'Coffee Crib',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.message),
          title: const Text('About'),
          onTap: () {
            setState(() {
              selectedPage = 'Messages';
            });
          },
        ),
      ]),
    );
  }
}
