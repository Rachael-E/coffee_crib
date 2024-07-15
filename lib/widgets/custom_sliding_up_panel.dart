import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CustomSlidingUpPanel extends StatelessWidget {
  final List<CoffeeFeature> coffeeFeatures;
  final Function(CoffeeFeature) zoomToCountryCallback;
  static const _panelHandleColor = Color.fromARGB(108, 121, 85, 72);
  static const _cardColor = Color.fromARGB(255, 233, 223, 221);

  final _panelController = PanelController();
  final _scrollController = ScrollController();

  CustomSlidingUpPanel({
    super.key,
    required this.zoomToCountryCallback,
    required this.coffeeFeatures,
  });

  @override
  Widget build(BuildContext context) {
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
                'Where in the world is coffee produced?',
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
      itemCount: coffeeFeatures.length,
      itemBuilder: (context, index) {
        final coffeeCountry = coffeeFeatures[index];
        return GestureDetector(
          onTap: () => zoomToCountryCallback(coffeeCountry),
          child: Card(
            color: _cardColor,
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