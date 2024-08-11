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
    return Scaffold(
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stones.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 150,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    stones[index]['imageUrl'] ?? "",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stones[index]['name'], style: Theme.of(context).textTheme.titleMedium),
                        Text(stones[index]['subtitle'], style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
