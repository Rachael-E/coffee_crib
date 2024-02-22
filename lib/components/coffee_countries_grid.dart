import 'package:coffee_crib/map_page.dart';
import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';
import 'package:coffee_crib/about_page.dart';

class CoffeeCountriesList extends StatelessWidget {
   const CoffeeCountriesList({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List<CoffeeFeature> items;

  // CoffeeFeature? _selectedCoffeeFeature;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 6 / 3,
      crossAxisCount: 4,
      padding: EdgeInsets.zero,
      children: List.generate(items.length, (index) {
        var coffeeCountry = items[index];
        return Center(
          child: Card(
            //   title: Text(coffeeCountry.properties.admin),
            //   leading: Icon(Icons.coffee_rounded),
            //   onTap: () {
            //     setState(() {
            //       _selectedCoffeeFeature = coffeeCountry;
            //     });
            //   }
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: const Color.fromARGB(255, 191, 92, 30),
            elevation: 10,
            child: InkWell(
              splashColor:
                  const Color.fromARGB(255, 221, 210, 199).withAlpha(30),
              onTap: () {
                
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         AboutPage(coffeeFeature: coffeeCountry),
                //   ),
                // );

                debugPrint(coffeeCountry.properties.admin);
              },
              child: Padding(
                
                padding: const EdgeInsets.all(5),
                child: Center(
                  child: SizedBox(
                    child: 
                        Text(
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
    );
  }
}
