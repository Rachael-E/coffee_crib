import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:coffee_crib/models/country_color_manager.dart';
import 'package:coffee_crib/widgets/custom_alert_dialog.dart';
import 'package:coffee_crib/widgets/custom_drawer.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.coffeeFeatures});
  final List<CoffeeFeature> coffeeFeatures;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mapViewController = ArcGISMapView.createController();
  final _graphicsOverlay = GraphicsOverlay();
  final _panelController = PanelController();
  final _scrollController = ScrollController();

  static const _appBarColor = Color.fromARGB(255, 112, 137, 112);
  static const _fabCardColor = Color.fromARGB(255, 233, 223, 221);
  static const _panelHandleColor = Color.fromARGB(108, 121, 85, 72);
  final _borderSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid, color: Colors.black, width: 1.0);
  final _colorManager = CountryColorManager();
  final _numberFormatter = NumberFormat('#,###,000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          ArcGISMapView(
            controllerProvider: () => _mapViewController,
            onTap: _selectGraphic,
            onMapViewReady: _onMapViewReady,
          ),
          _buildFloatingActionButton(),
          _buildSlidingUpPanel(),
        ],
      ),
    );
  }

  void _onMapViewReady() {
    _displayCoffeeCountriesOnMapAsGraphics();

    final map = ArcGISMap.withBasemapStyle(BasemapStyle.arcGISTopographic)
      ..initialViewpoint = Viewpoint.withLatLongScale(
          latitude: 4.671, longitude: -73.765, scale: 100000000);

    _mapViewController.arcGISMap = map;
    _mapViewController.graphicsOverlays.add(_graphicsOverlay);
  }

  void _selectGraphic(Offset localPosition) async {
    final result = await _mapViewController.identifyGraphicsOverlay(
      _graphicsOverlay,
      screenPoint: localPosition,
      tolerance: 22,
    );

    if (result.graphics.isEmpty || !mounted) return;

    final graphic = result.graphics.first;
    if (graphic.geometry != null) {
      _mapViewController.setViewpointAnimated(
          Viewpoint.fromTargetExtent(_expandedEnvelope(graphic.geometry!)),
          duration: 1);
    }

    final countryBagsProducedDouble =
        double.parse(graphic.attributes['coffeeBagsProduced']);
    final countryBagsProduced =
        _numberFormatter.format(countryBagsProducedDouble);
    final countryName = graphic.attributes['countryName'];

    _showCustomDialog(countryName, countryBagsProduced);
  }

  void _zoomToCountry(CoffeeFeature feature) {
    if (_graphicsOverlay.graphics.isEmpty) return;
    final geometry = _graphicsOverlay.graphics
        .firstWhere((graphic) =>
            graphic.attributes['countryName'] == feature.properties.admin)
        .geometry!;
    _mapViewController.setViewpointAnimated(
        Viewpoint.fromTargetExtent(_expandedEnvelope(geometry)),
        duration: 1);
  }

  void _displayCoffeeCountriesOnMapAsGraphics() {
    for (final coffeeCountry in widget.coffeeFeatures) {
      final geometry = _getFeatureGeometry(coffeeCountry);
      if (geometry != null) {
        _createAndDisplayGraphic(geometry, coffeeCountry);
      }
    }
  }

  void _createAndDisplayGraphic(
      Geometry geometry, CoffeeFeature coffeeFeature) {
    final simpleFillSymbol = SimpleFillSymbol(
      style: SimpleFillSymbolStyle.solid,
      color: _colorManager.getUniqueColor(),
      outline: _borderSymbol,
    );

    final graphic = Graphic(geometry: geometry, symbol: simpleFillSymbol);

    graphic.attributes.addAll({
      'coffeeBagsProduced': coffeeFeature.properties.coffeeProduction,
      'countryName': coffeeFeature.properties.admin,
    });

    _graphicsOverlay.graphics.add(graphic);
  }

  Geometry? _getFeatureGeometry(CoffeeFeature feature) {
    final coffeeFeatureCoordinatesList = feature.geometry.coordinates;
    Geometry? polygon;

    if (feature.geometry.type == CountryGeometryType.polygon) {
      final polygonBuilder =
          PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
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
      polygon = polygonBuilder.toGeometry();
    } else if (feature.geometry.type == CountryGeometryType.multiPolygon) {
      final polygonBuilderFromParts =
          PolygonBuilder.fromSpatialReference(SpatialReference.wgs84);
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
      polygon = polygonBuilderFromParts.toGeometry();
    }

    return polygon;
  }

  Geometry _expandedEnvelope(Geometry geometry) {
    final envelopeBuilder = EnvelopeBuilder.fromEnvelope(geometry.extent)
      ..expandBy(1.2);

    return envelopeBuilder.extent;
  }

  void _showCustomDialog(String countryName, String countryBagsProduced) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          countryName: countryName,
          countryBagsProduced: countryBagsProduced,
        );
      },
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
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(color: _appBarColor),
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.1,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: _fabCardColor,
        child: const Icon(Icons.zoom_out_map, color: Colors.black),
        onPressed: () => _mapViewController.setViewpointAnimated(
          Viewpoint.fromCenter(
            ArcGISPoint(x: 0, y: 0),
            scale: 100000000,
          ),
          duration: 1,
        ),
      ),
    );
  }

  Widget _buildSlidingUpPanel() {
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
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: widget.coffeeFeatures.length,
      itemBuilder: (context, index) {
        final coffeeCountry = widget.coffeeFeatures[index];
        return GestureDetector(
          onTap: () => _zoomToCountry(coffeeCountry),
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
