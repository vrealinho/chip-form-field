
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'BluetoothHelper.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

///
class ChipFormField extends FormField<int> {
  static final TextEditingController _textEditingController = new TextEditingController();
  final String device;
  final onRead;

  ChipFormField(
    context,
    this.device,
    this.onRead
  ) : super(
      builder: (FormFieldState<int> state) {
        return Row(
            children: <Widget>[
              Flexible(
                  child: Container(
                      margin: const EdgeInsets.only(left:16.0),
                      child: TextFormField(
                          controller: _textEditingController,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: 'Animal Eletronic Identifier',
                            hintText: 'Enter or read animal chip...',
                            //hintStyle: const TextStyle(color: Colors.grey),
                          ),
                          //onSubmitted: ...
                      )
                  )
              ),

              Container(
                margin: const EdgeInsets.only(top: 24.0),
                child: IconButton(
                  icon: const Icon(Icons.bluetooth),
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context) {
                      return ReadChipDialog(
                          device,
                          (chip) {
                            _textEditingController.text = chip;
                            onRead(chip);
                          }
                      );
                    });
                  }
                ),
              ),

            ]
        );
      }
  );

  String get chip => _textEditingController.text;
}

///
class ReadChipDialog extends StatefulWidget {
  final _onRead;
  final String _deviceName;

  ReadChipDialog(this._deviceName, this._onRead);

  @override
  _ReadChipDialogState createState() => _ReadChipDialogState(_deviceName, _onRead);
}

class _ReadChipDialogState  extends State<ReadChipDialog> {
  final _onRead;
  final String _deviceName;
  BuildContext _context;
  String _msg = '';
  Text _text;
  BluetoothConnection _connection;
  List<int> _blueMessage = new List<int>();

  _ReadChipDialogState(this._deviceName, this._onRead);

  @override
  void initState() {
    super.initState();

    print('[READ CHIP DIALOG] state: ' + BluetoothHelper.bluetoothState.toString());
    if (BluetoothHelper.bluetoothState != BluetoothState.STATE_ON) {
      print('[READ CHIP DIALOG] turn on Bluetooth');
      _msg = 'ENABLING BLUETOOTH\n';
      BluetoothHelper.enableBluetooth();

      // listen for chnages on bluetooth state
      BluetoothHelper.onBluetoothStateChanged((state) {
        print('[READ CHIP DIALOG] bluetooth state changed ' + state.toString());
        if (state == BluetoothState.STATE_ON) {
          _connectTo(_deviceName, _onRead);
        }
      });
    }
    else {
      _msg = 'CONNECTING TO READER\n' + _deviceName;
      _connectTo(_deviceName, _onRead);
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    _text = Text(_msg,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  _dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(16),
          //margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              SizedBox(height: 8.0),
              Text(
                'PLEASE WAIT',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              _text,
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                  elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.orangeAccent,
                  onPressed: () {
                    _disconnect();
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _connectTo(deviceName, onRead) async {
    // find BluetoothDevice for 'deviceName' and connect to that device
    BluetoothHelper.bondedDevices.forEach((bluetoothDevice) async {
      print('READ CHIP DIALOG] dev: ' + bluetoothDevice.name);
      if (bluetoothDevice.name == deviceName) {
        try {
          // establish connection to the device
          print('[READ CHIP DIALOG] _connectTo Connected to the device ' + bluetoothDevice.name);
          setState(() {_msg = 'CONNECTING TO READER\n' + bluetoothDevice.name;});

          _connection = await BluetoothConnection.toAddress(bluetoothDevice.address);
          _connection.input.listen((Uint8List data) {
            data.forEach((b) {
              if (b == 13) {
                // process message
                String chip = ascii.decode(_blueMessage.sublist(9, 25)).replaceAll(' ', '');
                onRead(chip);
                _blueMessage = new List<int>();
                _disconnect();
                Navigator.of(_context).pop();
              }
              else {
                _blueMessage.add(b);
              }
            });
          }).onDone(() {
            print('[READ CHIP DIALOG] _connectTo Disconnected by remote request');
          });

          int delays = 0;
          Future.doWhile(() {
            if (_connection.isConnected) {
              setState(() {_msg = 'PASS READER AT THE\nANIMAL';});
              return false;
            }
            else if (delays > 40) {
              setState(() {_msg = 'CANNOT CONNECT TO\nREADER';});
              return false;
            }
            else {
              Future.delayed(Duration(milliseconds: 100), () {
                delays++;
              });
              return true;
            }
          }).then((_){});
        }
        catch (exception) {
          print('[READ CHIP DIALOG] _connectTo Cannot connect, exception occured ' + exception.toString());
          setState(() {_msg = 'CANNOT CONNECT TO\nREADER';});
        }
      }
    });
  }

  void _disconnect() {
    if (_connection != null && _connection.isConnected) {
      _connection.finish();
    }
  }
}