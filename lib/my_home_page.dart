import 'package:coffee_crib/components/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/map_page.dart';
import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CoffeeCountries? _coffeeCountries;
  final GlobalKey<MapPageState> mapPageKey = GlobalKey<MapPageState>();
  final PanelController _panelController = PanelController();
  Map<String, bool> drawnCoffeeCountries = {}; // Map to track drawn coffee countries

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home Page"),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          // Map widget in the background
          MapPage(key: mapPageKey),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              child: const Icon(Icons.list, color: Colors.white),
              onPressed: () {
                _panelController.open();
              },
            ),
          ),
          // SlidingUpPanel for the coffee countries list
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height * 0.4,
            panel: _coffeeCountries != null
                ? GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns
                      childAspectRatio: 3, // Adjust the ratio to fit your design
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: _coffeeCountries!.features.length,
                    itemBuilder: (context, index) {
                      var coffeeCountry = _coffeeCountries!.features[index];
                      return GestureDetector(
                        onTap: () {
                          mapPageKey.currentState?.zoomToCountry(coffeeCountry);
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Center(
                              child: Text(
                                coffeeCountry.properties.admin,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()), // if coffee countries don't load
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
    String jsonFilePath = 'assets/FullCoffeeCountries_GEOJSON.geojson';

    // Read the JSON file
    rootBundle.loadString(jsonFilePath).then((String contents) {
      coffeeCountriesFromJson = coffeeCountriesDataFromJson(contents);

      // Parse the JSON data
      setState(() {
        _coffeeCountries = coffeeCountriesFromJson;
        _coffeeCountries!.features.sort((a, b) =>
            a.properties.admin.compareTo(b.properties.admin)); // Sort alphabetically
        drawAllCoffeeCountries();
      });
    }).catchError((error) {
      print('Error reading JSON file: $error');
    });
  }

  void drawAllCoffeeCountries() {
    if (_coffeeCountries != null) {
      for (var coffeeCountry in _coffeeCountries!.features) {
        drawCoffeeCountriesPolygons(coffeeCountry);
      }
    }
  }

  void drawCoffeeCountriesPolygons(CoffeeFeature feature) {
    if (drawnCoffeeCountries.containsKey(feature.properties.admin)) {
      return;
    }
    drawnCoffeeCountries[feature.properties.admin] = true;

    var polygonBuilder = PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
    var polygonBuilderFromParts = PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);

    var coffeeFeatureCoordinates = feature.geometry.coordinates;

    if (coffeeFeatureCoordinates.length == 1) {
      // if country is a single part polygon
      for (var coordinate in coffeeFeatureCoordinates[0]) {
        var lat = coordinate[0];
        var long = coordinate[1];
        polygonBuilder.addPoint(
          ArcGISPoint(
            x: lat,
            y: long,
            spatialReference: SpatialReference.wgs84,
          ),
        );
      }
      drawAndNavigate(polygonBuilder, feature);
    } else {
      // if country is a multipart
      for (var part in coffeeFeatureCoordinates) {
        var mutablePart = MutablePart.withSpatialReference(SpatialReference.wgs84);
        for (var coordinates in part) {
          for (var coordinate in coordinates) {
            var lat = coordinate[0];
            var long = coordinate[1];
            mutablePart.addPoint(
              ArcGISPoint(
                x: lat,
                y: long,
                spatialReference: SpatialReference.wgs84,
              ),
            );
          }
        }
        polygonBuilderFromParts.parts.addPart(mutablePart: mutablePart);
      }
      drawAndNavigate(polygonBuilderFromParts, feature);
    }
  }

  void drawAndNavigate(PolygonBuilder polygonBuilder, CoffeeFeature feature) {
    var polygon = polygonBuilder.toGeometry();
    mapPageKey.currentState?.addToGraphicsOverlay(polygon, feature);
  }
}
