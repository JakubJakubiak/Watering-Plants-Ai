import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DataVisulisation extends StatefulWidget {
  @override
  _DataVisulisationState createState() => _DataVisulisationState();
}

class _DataVisulisationState extends State<DataVisulisation> {
  List<dynamic> stones = [];

  @override
  void initState() {
    super.initState();
    loadStones();
  }

  Future<void> loadStones() async {
    String jsonString = await rootBundle.loadString('lib/moduls/data_jeson/data_Visulisation.json');
    setState(() {
      stones = json.decode(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stones.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Image.network(
              stones[index]['imageUrl'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(stones[index]['name']),
            subtitle: Text(stones[index]['subtitle']),
            onTap: () {},
          ),
        );
      },
    );
  }
}
