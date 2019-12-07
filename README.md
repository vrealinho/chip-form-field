# `chip-form-field`
Animal Identifier RFID Reader Widget for HC-06 chipset

# How to use it
1. This Widget use package `flutter_bluetooth_serial` started by @github/Edufolly. Please follow the instructions provided to use this package.

2. Add `BluetoothHelper.dart` and `ChipFormField.dart` to your projet.

3. Create a new ChipFormField widget and add it to your layout
```
ChipFormField _chipFormField = ChipFormField(context, 'HC-06', (chip) {
      print('CHIP: ' + chip);
    });
```

4. Use `_chipFormField.chip` to get the animal identifier whenever needed

5. That's it.

# Example
```
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
```

Widget |  Connecting to reader  |  Reading chip  |
:---:|:---:|:---:|
![](https://github.com/vrealinho/chip-form-field/blob/master/screenshots/screen1.png?raw=true)  |  ![](https://github.com/vrealinho/chip-form-field/blob/master/screenshots/screen2.png?raw=true)  |  ![](https://github.com/vrealinho/chip-form-field/blob/master/screenshots/screen4.png?raw=true)

