import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import './BleController.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final BleController _controller = Get.put(BleController());

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<List<ScanResult>>(
                stream: _controller.scanResults,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data![index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(data.device.platformName),
                            subtitle: Text(data.device.remoteId.str),
                            trailing: Text(data.rssi.toString()),
                            onTap: () => _controller.connectToDevice(data.device),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No Device Found"));
                  }
                },
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _controller.scanDevices();
                  },
                  child: const Text("Scan"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.disconnect();
                  },
                  child: const Text("Disconnect from all")
                ),
              ]
            ),
          ]
        )
      ),
    );
  }
}