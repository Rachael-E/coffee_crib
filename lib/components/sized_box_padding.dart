import 'package:coffee_crib/models/coffee_countries.dart';
import 'package:flutter/material.dart';

class SizedBoxPadding extends StatelessWidget {
  const SizedBoxPadding({
    super.key,
    required this.coffeeCountry,
  });

  final CoffeeFeature coffeeCountry;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
