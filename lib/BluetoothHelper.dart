///
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Bluetooth helper
class BluetoothHelper {
  static BluetoothHelper _instance = new BluetoothHelper();
  static BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  static String _myAddress = "";
  static String _myName = "";
  static List<BluetoothDevice> _bondedDevices = List<BluetoothDevice>();

  BluetoothHelper() {
    // Get mac address
    FlutterBluetoothSerial.instance.address.then((address) {
      _myAddress = address;
      print('[BLUETOOTH HELPER] My address: $_myAddress');
    });

    // Get name
    FlutterBluetoothSerial.instance.name.then((name) {
      _myName = name;
      print('[BLUETOOTH HELPER] My name: $_myName');
    });

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
        _bluetoothState = state;
        print('[BLUETOOTH HELPER] bluetooth state: $_bluetoothState');
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      print('[BLUETOOTH HELPER] bluetooth state changed: $_bluetoothState');
      FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
        _bondedDevices = bondedDevices;
      });
    });

    // Get list of bonded devices
    FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
      _bondedDevices = bondedDevices;
    });
  }

  /// Returns the Bluetooth state
  static BluetoothState get bluetoothState => _bluetoothState;

  /// Returns the name of the local device
  static String get myName => _myName;

  /// Returns the MAC address of the local device
  static String get myAddress => _myAddress;

  /// Returns a list of bonded devices
  static List<BluetoothDevice> get bondedDevices => _bondedDevices;

  /// Enable Bluetooth
  static void enableBluetooth() => FlutterBluetoothSerial.instance.requestEnable();

  /// Disable Bluetooth
  static void disableBluetooth() => FlutterBluetoothSerial.instance.requestDisable();

  /// Defines a callback of changes on Bluetooth state
  static void onBluetoothStateChanged(onBluetoothStateChanged) {
    // Listen for futher state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      print('[BLUETOOTH HELPER] bluetooth state changed: $_bluetoothState');
      FlutterBluetoothSerial.instance.getBondedDevices().then((List<BluetoothDevice> bondedDevices) {
        _bondedDevices = bondedDevices;
        onBluetoothStateChanged(state);
      });
    });
  }
}