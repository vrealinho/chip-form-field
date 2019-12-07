import 'package:flutter/material.dart';
import 'ChipFormField.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chip reader Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'Chip reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    // create a new ChipFormField widget to get an animal identifier
    // use _chipFormField.chip to get the animal identifier whenever needed
    //
    ChipFormField _chipFormField = ChipFormField(context, 'HC-06', (chip) {
      print('CHIP: ' + chip);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _chipFormField,
    );
  }
}
