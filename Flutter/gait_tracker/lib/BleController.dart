import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:typed_data';

class BleController extends GetxController {
  final RxList<ChartData> _latestAnkleData = RxList<ChartData>.filled(1, ChartData(0, 0), growable: true);
  final RxList<ChartData> _latestKneeData = RxList<ChartData>.filled(1, ChartData(0, 0), growable: true);
  final RxList<ChartData> _latestHipData = RxList<ChartData>.filled(1, ChartData(0, 0), growable: true);
  double ankleIndex = 0, kneeIndex = 0, hipIndex = 0;
  late BluetoothDevice kneeDevice, hipDevice, ankleDevice;
  bool _canWriteToAnkleList = false, _canWriteToKneeList = false, _canWriteToHipList = false;

  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    _canWriteToAnkleList = false;
    _canWriteToKneeList = false;
    _canWriteToHipList = false;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 15));
    if(device.platformName == "AnkleArduinoNano33BLE"){
      ankleDevice = device;
    } else if (device.platformName == "KneeArduinoNano33BLE") {
      kneeDevice = device;
    } else if (device.platformName == "HipArduinoNano33BLE") {
      hipDevice = device;
    }

    device.connectionState.listen((isConnected) async {
      if (isConnected == BluetoothConnectionState.connected) {
        // Discover services and characteristics
        List<BluetoothService> services = await device.discoverServices();
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  int receivedData = _convertToInt(value);
                  _updateReceivedData(receivedData, device.platformName);
                }
              });
              // Enable notifications or indications
              characteristic.setNotifyValue(true);
            }
          }
        }
      }
    });
  }

  int _convertToInt(List<int> incomingList){
    return ByteData.view(Int16List.fromList(incomingList).buffer).getInt8(0);
  }

  void _updateReceivedData(int data, String deviceName) {
    if(deviceName == "AnkleArduinoNano33BLE" && _canWriteToAnkleList){
      _latestAnkleData.add(ChartData(ankleIndex, data));
    } else if (deviceName == "KneeArduinoNano33BLE" && _canWriteToKneeList) {
      _latestKneeData.add(ChartData(kneeIndex, data));
    } else if (deviceName == "HipArduinoNano33BLE" && _canWriteToHipList) {
      _latestHipData.add(ChartData(hipIndex, data));
    }
  }

  RxList<ChartData> getLatestAnkleData() {
    return _latestAnkleData;
  }

  RxList<ChartData> getLatestHipData() {
    return _latestHipData;
  }

  RxList<ChartData> getLatestKneeData() {
    return _latestKneeData;
  }

  void clearAnkleData() {
    ankleIndex = 0;
    _latestAnkleData.clear();
    _latestAnkleData.add(ChartData(0, 0));
  }

  void clearHipData() {
    hipIndex = 0;
    _latestHipData.clear();
    _latestHipData.add(ChartData(0, 0));
  }

  void clearKneeData() {
    kneeIndex = 0;
    _latestKneeData.clear();
    _latestKneeData.add(ChartData(0, 0));
  }

  bool canWriteToAnkle() {
    return _canWriteToAnkleList;
  }

  bool canWriteToKnee() {
    return _canWriteToKneeList;
  }
  
  bool canWriteToHip() {
    return _canWriteToHipList;
  }

  void pauseAnkleChart() {
    _canWriteToAnkleList = !_canWriteToAnkleList;
  }

  void pauseKneeChart() {
    _canWriteToKneeList = !_canWriteToKneeList;
  }

  void pauseHipChart() {
    _canWriteToHipList = !_canWriteToHipList;
  }

  void pauseAllCharts() {
    _canWriteToAnkleList = false;
    _canWriteToHipList = false;
    _canWriteToKneeList = false;
  }

  void resumeAllCharts() {
    _canWriteToAnkleList = true;
    _canWriteToHipList = true;
    _canWriteToKneeList = true;
  }

  void clearAllData() {
    ankleIndex = 0;
    _latestAnkleData.clear();
    kneeIndex = 0;
    _latestKneeData.clear();
    hipIndex = 0;
    _latestHipData.clear();
  }

  void disconnect() {
    _canWriteToAnkleList = false;
    _canWriteToKneeList = false;
    _canWriteToHipList = false;
    kneeDevice.disconnect(queue: false, timeout: 1);
    hipDevice.disconnect(queue: false, timeout: 1);
    ankleDevice.disconnect(queue: false, timeout: 1);
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}

class ChartData {
  final double x;
  final int y;
  ChartData(this.x, this.y);
}
