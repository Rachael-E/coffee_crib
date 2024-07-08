import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:coffee_crib/components/custom_drawer.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:coffee_crib/map_page.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.coffeeFeatures});
  final List<CoffeeFeature> coffeeFeatures;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PanelController _panelController = PanelController();
  final ScrollController _scrollController = ScrollController();

  static const _appBarColor = Color.fromARGB(255, 112, 137, 112);
  static const _fabCardColor = Color.fromARGB(255, 233, 223, 221);
  static const _panelHandleColor = Color.fromARGB(108, 121, 85, 72);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          MapPage(key: _mapPageKey),
          _buildFloatingActionButton(context),
          _buildSlidingUpPanel(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Row(
        children: [
          SizedBox(width: 10),
          Text(
            "Coffee Countries",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        color: _appBarColor,
      ),
    );
  }

  Positioned _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.1,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: _fabCardColor,
        child: const Icon(Icons.zoom_out_map, color: Colors.black),
        onPressed: () {
          _mapPageKey.currentState?.showWorldView();
        },
      ),
    );
  }

  SlidingUpPanel _buildSlidingUpPanel() {
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: MediaQuery.of(context).size.height * 0.08,
      maxHeight: MediaQuery.of(context).size.height * 0.4,
      panel: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/coffee_background.png'), // AI-generated image
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _buildPanelContent(),
      ),
      isDraggable: true,
    );
  }

  Widget _buildPanelContent() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: _panelHandleColor,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Where in the world is coffee produced?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildCountryContainer(),
        ),
      ],
    );
  }

  Widget _buildCountryContainer() {
    if (_coffeeCountries == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _coffeeCountries!.features.length,
      itemBuilder: (context, index) {
        var coffeeCountry = _coffeeCountries!.features[index];
        return GestureDetector(
          onTap: () {
            _mapPageKey.currentState?.zoomToCountry(coffeeCountry);
          },
          child: Card(
            color: _fabCardColor,
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
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

    }
  }

  void _buildPolygon(CoffeeFeature feature) {
    if (drawnCoffeeCountries.containsKey(feature.properties.admin)) {
      return;
    }
    drawnCoffeeCountries[feature.properties.admin] = true;

    final polygonBuilder =
        PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
    final polygonBuilderFromParts =
        PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
    final coffeeFeatureCoordinatesList = feature.geometry.coordinates;

    if (feature.geometry.type == CountryGeometryType.polygon) {
      // if country is a single part polygon
      for (final coordinates in coffeeFeatureCoordinatesList[0]) {
        final lat = coordinates[0];
        final long = coordinates[1];
        polygonBuilder.addPoint(
          ArcGISPoint(
            x: lat,
            y: long,
            spatialReference: SpatialReference.wgs84,
          ),
        );
      }
      _createGraphicFromPolygonBuilder(polygonBuilder, feature);
    } else if (feature.geometry.type == CountryGeometryType.multiPolygon)  {
      // if country is a multipart polygon
      for (final part in coffeeFeatureCoordinatesList) {
        final mutablePart =
            MutablePart.withSpatialReference(SpatialReference.wgs84);
        for (final list in part) {
          for (final coordinates in list) {
            final lat = coordinates[0];
            final long = coordinates[1];
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
      _createGraphicFromPolygonBuilder(polygonBuilderFromParts, feature);
    }
  }

  void _createGraphicFromPolygonBuilder(PolygonBuilder polygonBuilder, CoffeeFeature feature) {
    final polygon = polygonBuilder.toGeometry();
    _mapPageKey.currentState?.configureGraphic(polygon, feature);
  }
}
