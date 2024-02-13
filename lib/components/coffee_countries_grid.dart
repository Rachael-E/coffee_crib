import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';
import 'package:coffee_crib/about_page.dart';

class CoffeeCountriesGrid extends StatelessWidget {
  const CoffeeCountriesGrid({
    super.key,
    required List<CoffeeFeature> items,
  }) : _items = items;

  final List<CoffeeFeature> _items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 5 / 3,
      crossAxisCount: 2,
      // padding: const EdgeInsets.all(20),
      children: List.generate(_items.length, (index) {
        // var properties = _items[index]["properties"];
        var coffeeCountry = _items[index];
        return Center(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            color: const Color.fromARGB(255, 191, 92, 30),
            elevation: 10,
            child: InkWell(
              splashColor:
                  const Color.fromARGB(255, 221, 210, 199).withAlpha(30),
              onTap: () {

                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => AboutPage(coffeeFeature: coffeeCountry),
            ),
          );



                  debugPrint(coffeeCountry.properties.admin);

                // debugPrint(properties["Description"]);
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 100,
                  width: 200,
                  child: Column(
                    children: [
                      Text(
                        coffeeCountry.properties.admin,
                        // properties.properties.admin,
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
    );
  }
}
