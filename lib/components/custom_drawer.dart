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
            'About the app',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Built with the ArcGIS Maps SDK for Flutter (beta)',
          
          ),
        ),
        ListTile(
          leading: Icon(Icons.bar_chart),
          title: Text('Coffee data from early 2020s, generalised from publically available sources',
                      style: TextStyle(
              color: Colors.black,
              fontSize: 14,
            )),
        ),
        ListTile(
          leading: Icon(Icons.warning),
          title: Text('Country borders are generalised'),
        ),
      ]),
    );
  }
}
