import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String selectedPage = '';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: const <Widget>[
         DrawerHeader(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 199, 230, 204),
          ),
          child:  Text(
            'About Coffee Crib',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Built with the ArcGIS Maps SDK for Flutter (beta)'),
        ),
        ListTile(
          leading: Icon(Icons.bar_chart),
          title: Text('Data source: International Coffee Organization'),
        ),
        ListTile(
          leading: Icon(Icons.warning),
          title: Text('Country borders may be less accurate when zoomed in'),
        ),
      ]),
    );
  }
}
