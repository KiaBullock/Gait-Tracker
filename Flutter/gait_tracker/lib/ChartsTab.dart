import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import './BleController.dart';
import './ImageUtils.dart';

class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  _ChartsTabState createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  final BleController _controller = Get.put(BleController());
  List<ChartData> ankleDataList = [];
  List<ChartData> kneeDataList = [];
  List<ChartData> hipDataList = [];

  static const int _updateIntervalMillis = 250;
  final double _updateIntervalSec = _updateIntervalMillis/1000;

  ScreenshotController screenshotController = ScreenshotController();

  final GlobalKey _ankleContainer = GlobalKey();
  final GlobalKey _kneeContainer = GlobalKey();
  final GlobalKey _hipContainer = GlobalKey();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: _updateIntervalMillis),
        (timer) {
      setState(() {
        ankleDataList = List.from(_controller.getLatestAnkleData());
        kneeDataList = List.from(_controller.getLatestKneeData());
        hipDataList = List.from(_controller.getLatestHipData());
        if(_controller.canWriteToAnkle()){
          _controller.ankleIndex += _updateIntervalSec;
        }
        if(_controller.canWriteToHip()){
          _controller.hipIndex += _updateIntervalSec;
        }
        if(_controller.canWriteToKnee()){
          _controller.kneeIndex += _updateIntervalSec;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Screenshot(
            controller: screenshotController,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(//Ankle
                  children: [
                    Container(
                    // Ankle Chart
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      height: 220,
                      width: 290,
                      child: RepaintBoundary(
                        key: _ankleContainer,
                        child: SfCartesianChart(
                          enableAxisAnimation: false,
                          title: const ChartTitle(
                            text: "Real-Time Ankle Chart",
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10
                            )
                          ),
                          primaryXAxis: const NumericAxis(
                            title: AxisTitle(
                              text: "Time (seconds)",
                              textStyle: TextStyle(fontSize: 8),
                            ),
                            crossesAt: 0,
                            interval: 5,
                          ),
                          primaryYAxis: const NumericAxis(
                            title: AxisTitle(
                              text: "Changes in Flexion (° Degrees)",
                              textStyle: TextStyle(fontSize: 8),
                            ),
                            minimum: -20,
                            maximum: 60,
                            interval: 10,
                            minorGridLines: MinorGridLines(width: 0),
                          ),
                          series: <CartesianSeries>[
                            SplineSeries<ChartData, double>(
                              dataSource: ankleDataList,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: const Color.fromRGBO(20, 122, 20, 1),
                              animationDuration: 0,
                            ),
                          ]
                        ),
                      ),
                    ),
                  Container(
                    // Ankle Chart Buttons
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    height: 125,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              _controller.pauseAnkleChart();
                            },
                          child: Text(
                            _controller.canWriteToAnkle()
                              ? "Pause"
                              : "Resume",
                          style: TextStyle(fontSize: 12))),
                        ElevatedButton(
                          onPressed: () {
                            _controller.clearAnkleData();
                          },
                          child: const Text("Clear",
                            style: TextStyle(fontSize: 12)
                          )
                        )
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 1),
                Row(//Knee
                    children: [
                  Container(
                    // Knee Chart
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    height: 220,
                    width: 290,
                    child: RepaintBoundary(
                      key: _kneeContainer,
                      child: SfCartesianChart(
                          enableAxisAnimation: false,
                          title: const ChartTitle(
                            text: "Real-Time Knee Chart",
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 10
                            )
                          ),
                          primaryXAxis: const NumericAxis(
                            title: AxisTitle(
                                text: "Time (seconds)",
                                textStyle: TextStyle(fontSize: 8)),
                            crossesAt: 0,
                            interval: 5,
                          ),
                          primaryYAxis: const NumericAxis(
                            title: AxisTitle(
                                text: "Changes in Flexion (° Degrees)",
                                textStyle: TextStyle(fontSize: 8)),
                            minimum: -20,
                            maximum: 60,
                            interval: 10,
                            minorGridLines: MinorGridLines(width: 0),
                          ),
                          series: <CartesianSeries>[
                            SplineSeries<ChartData, double>(
                              dataSource: kneeDataList,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              color: Color.fromARGB(255, 10, 41, 216),
                              animationDuration: 0,
                            ),
                          ]),
                    ),
                  ),
                  Container(
                    // Knee Chart Buttons
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    height: 125,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _controller.pauseKneeChart();
                          },
                          child: Text(
                            _controller.canWriteToKnee()
                              ? "Pause"
                              : "Resume",
                            style: TextStyle(fontSize: 12)
                          )
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _controller.clearKneeData();
                          },
                          child: const Text("Clear",
                            style: TextStyle(fontSize: 12)
                          )
                        )
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 1),
                Row(//Hip
                  children: [
                    Container(
                    // Hip Chart
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      height: 220,
                      width: 290,
                      child: RepaintBoundary(
                        key: _hipContainer,
                        child: SfCartesianChart(
                          enableAxisAnimation: false,
                            title: const ChartTitle(
                              text: "Real-Time Hip Chart",
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10
                              )
                            ),
                            primaryXAxis: const NumericAxis(
                              title: AxisTitle(
                                text: "Time (seconds)",
                                textStyle: TextStyle(fontSize: 8)
                              ),
                              crossesAt: 0,
                              interval: 5,
                            ),
                            primaryYAxis: const NumericAxis(
                              title: AxisTitle(
                                  text: "Changes in Flexion (° Degrees)",
                                  textStyle: TextStyle(fontSize: 8)),
                              minimum: -20,
                              maximum: 60,
                              interval: 10,
                              minorGridLines: MinorGridLines(width: 0),
                            ),
                            series: <CartesianSeries>[
                              SplineSeries<ChartData, double>(
                                dataSource: hipDataList,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                color: const Color.fromARGB(255, 255, 0, 0),
                                animationDuration: 0,
                              ),
                            ]),
                      ),
                    ),
                    Container(
                    // Hip Chart Buttons
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      height: 125,
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _controller.pauseHipChart();
                            },
                            child: Text(
                              _controller.canWriteToHip()
                                ? "Pause"
                                : "Resume",
                              style: TextStyle(fontSize: 12)
                            )
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _controller.clearHipData();
                            },
                            child: const Text("Clear",
                            style: TextStyle(fontSize: 12))
                          )
                        ],
                      ),
                    ),
                ]),
                const SizedBox(height: 1),
                Container(
                  //Global buttons
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (_controller.canWriteToAnkle() &&
                                _controller.canWriteToHip() &&
                                _controller.canWriteToKnee()) {
                              _controller.pauseAllCharts();
                            } else {
                              _controller.resumeAllCharts();
                            }
                          },
                          child: Text((_controller.canWriteToAnkle() &&
                                  _controller.canWriteToHip() &&
                                  _controller.canWriteToKnee())
                              ? "Pause All"
                              : "Resume All")),
                      ElevatedButton(
                          onPressed: () {
                            _controller.clearAllData();
                          },
                          child: const Text("Clear All")),
                      ElevatedButton(
                          onPressed: () async {
                            _takeScreenshot();
                          },
                          child: const Text("Share")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _takeScreenshot() async {
    RenderRepaintBoundary ankleBoundary = _ankleContainer.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    RenderRepaintBoundary kneeBoundary = _kneeContainer.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    RenderRepaintBoundary hipBoundary = _hipContainer.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image ankleImage = await ankleBoundary.toImage(pixelRatio: 3.0);
    ui.Image kneeImage = await kneeBoundary.toImage(pixelRatio: 3.0);
    ui.Image hipImage = await hipBoundary.toImage(pixelRatio: 3.0);
    ByteData? ankleByteData =
        await ankleImage.toByteData(format: ui.ImageByteFormat.png);
    ByteData? kneeByteData =
        await kneeImage.toByteData(format: ui.ImageByteFormat.png);
    ByteData? hipByteData =
        await hipImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List firstPngBytes = ankleByteData!.buffer.asUint8List();
    Uint8List secondPngBytes = kneeByteData!.buffer.asUint8List();
    Uint8List thirdPngBytes = hipByteData!.buffer.asUint8List();

    var image = await ImageUtils.mergeImages(
        [firstPngBytes, secondPngBytes, thirdPngBytes]);

    final tempDir = await getTemporaryDirectory();
    await File('${tempDir.path}/screenshot.png').writeAsBytes(image);
    await Share.shareFiles(['${tempDir.path}/screenshot.png']);
  }
}
