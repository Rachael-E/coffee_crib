import 'package:flutter/material.dart';

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
