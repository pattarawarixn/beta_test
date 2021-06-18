import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:expandable/expandable.dart';
import 'package:adobe_xd/adobe_xd.dart';
import 'package:chartsdata/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  return runApp(_ChartApp());
}

class _Data {
  final String id;
  final String rawData;
  final double temperature;
  final double humid;
  final DateTime timestamp;
  final double barometer;
  final double visible_light;
  final double ir_light;
  final String node;
  final int flag;

  _Data(
      {@required this.id,
      @required this.rawData,
      @required this.temperature,
      @required this.humid,
      @required this.timestamp,
      @required this.barometer,
      @required this.visible_light,
      @required this.ir_light,
      @required this.node,
      @required this.flag});

  factory _Data.fromJson(Map<String, dynamic> json) {
    return _Data(
        id: json['_id'].toString(),
        rawData: json['rawData'].toString(),
        temperature: double.parse(json['temperature'].toStringAsFixed(2)),
        humid: double.parse(json['humid'].toStringAsFixed(2)),
        timestamp: new DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(json['timestamp'].toString()),
        barometer: double.parse(json['barometer'].toStringAsFixed(2)),
        visible_light: double.parse(json['visible_light'].toStringAsFixed(2)),
        ir_light: double.parse(json['ir_light'].toStringAsFixed(2)),
        node: json['node'].toString(),
        flag: int.parse(json['flag'].toString()));
  }
}

class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.pink),
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  _MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  bool isFirstTime = true;
  List<_Data> lastestData;
  var last;
  Timer timer;
  ChartSeriesController _chartSeriesController1;
  ChartSeriesController _chartSeriesController2;
  ChartSeriesController _chartSeriesController3;
  ChartSeriesController _chartSeriesController4;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(milliseconds: 500), (Timer timer) => _updateData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<dynamic> _getData() async {
    final response = await http.get(Uri.parse(
        'http://engineer.narit.or.th/ajax/weather_module/api_test.php'));
    var map = json.decode(response.body);
    return map;
  }

  _updateData() async {
    if (last != null) {
      try {
        final response = await http.get(Uri.parse(
            'http://engineer.narit.or.th/ajax/weather_module/api_test.php?id=' +
                last));
        var map = json.decode(response.body);

        List<_Data> temp =
            (map as List).map((item) => _Data.fromJson(item)).toList();

        last = temp.last.id;

        int beforeCount = lastestData.length - 1;

        temp.forEach((element) {
          if (element.timestamp != null) {
            lastestData.add(element);
          }
        });

        int afterCount = lastestData.length - 1;

        int countRemove = afterCount - beforeCount - 1;

        lastestData.removeRange(0, countRemove);

        _chartSeriesController1?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController2?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController3?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
        _chartSeriesController4?.updateDataSource(
            addedDataIndexes: <int>[beforeCount],
            removedDataIndexes: <int>[countRemove]);
      } catch (e) {}
    }
  }

  List<_Data> _get(data) {
    List<_Data> listData =
        (data as List).map((item) => _Data.fromJson(item)).toList();
    return listData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: ExpandableTheme(
            data: const ExpandableThemeData(
              iconColor: Colors.blue,
              useInkWell: true,
            ),
            child: ListView(physics: const BouncingScrollPhysics(), children: <
                Widget>[
              Card1(),
              Card2(),
              Card3(),
              FutureBuilder(
                  future: _getData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (isFirstTime) {
                        lastestData = _get(snapshot.data);
                        last = lastestData.last.id;
                        isFirstTime = false;
                      }

///////////CHARTS////////////////
                      return ListView(
                        children: [
                          Text("Temperature"),
                          SfCartesianChart(
                              primaryXAxis: DateTimeAxis(
                                  labelRotation: 90,
                                  intervalType: DateTimeIntervalType.seconds,
                                  dateFormat: DateFormat.Hms()),
                              margin: EdgeInsets.all(15),
                              // Chart title
                              // Enable legend
                              primaryYAxis: NumericAxis(
                                isVisible: true,
                                numberFormat: NumberFormat("##.##", "en_US"),
                                maximumLabelWidth: 25,
                                decimalPlaces: 0,
                                minimum: 0,
                                maximum: 100,
                                interval: 10,
                              ),
                              legend: Legend(isVisible: false),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: false),
                              series: <ChartSeries<_Data, DateTime>>[
                                LineSeries<_Data, DateTime>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      // Assigning the controller to the _chartSeriesController.
                                      _chartSeriesController1 = controller;
                                    },
                                    dataSource: lastestData,
                                    xValueMapper: (_Data test, _) =>
                                        test.timestamp,
                                    yValueMapper: (_Data test, _) =>
                                        test.temperature,
                                    name: 'Temperature',
                                    // Enable data label
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true)),
                              ]),
                          Text("Humidity"),
                          SfCartesianChart(
                              primaryXAxis: DateTimeAxis(
                                labelRotation: 90,
                                intervalType: DateTimeIntervalType.seconds,
                                dateFormat: DateFormat.Hms(),
                              ),
                              // Chart title
                              // Enable legend
                              primaryYAxis: NumericAxis(
                                isVisible: true,
                                numberFormat: NumberFormat("###.##", "en_US"),
                                maximumLabelWidth: 25,
                                decimalPlaces: 0,
                                minimum: 0,
                                maximum: 100,
                                interval: 10,
                              ),
                              legend: Legend(isVisible: false),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries<_Data, DateTime>>[
                                LineSeries<_Data, DateTime>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      // Assigning the controller to the _chartSeriesController.
                                      _chartSeriesController2 = controller;
                                    },
                                    dataSource: lastestData,
                                    xValueMapper: (_Data test, _) =>
                                        test.timestamp,
                                    yValueMapper: (_Data test, _) => test.humid,
                                    name: 'Humidity',
                                    // Enable data label
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true)),
                              ]),
                          Text("Barometer"),
                          SfCartesianChart(
                              primaryXAxis: DateTimeAxis(
                                  labelRotation: 90,
                                  intervalType: DateTimeIntervalType.seconds,
                                  dateFormat: DateFormat.Hms()),
                              // Chart title
                              // Enable legend
                              primaryYAxis: NumericAxis(
                                isVisible: true,
                                numberFormat: NumberFormat("##.###", "en_US"),
                                maximumLabelWidth: 25,
                                //minimum: 0,
                                //maximum: 100,
                                //interval: 10,
                              ),
                              legend: Legend(isVisible: false),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries<_Data, DateTime>>[
                                LineSeries<_Data, DateTime>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      // Assigning the controller to the _chartSeriesController.
                                      _chartSeriesController3 = controller;
                                    },
                                    dataSource: lastestData,
                                    xValueMapper: (_Data test, _) =>
                                        test.timestamp,
                                    yValueMapper: (_Data test, _) =>
                                        test.barometer,
                                    name: 'Barometer',
                                    color: Colors.red,
                                    // Enable data label
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true)),
                              ]),
                          Text("Visible Light"),
                          SfCartesianChart(
                              primaryXAxis: DateTimeAxis(
                                  labelRotation: 90,
                                  intervalType: DateTimeIntervalType.seconds,
                                  dateFormat: DateFormat.Hms()),
                              // Chart title
                              // Enable legend
                              primaryYAxis: NumericAxis(
                                  isVisible: true,
                                  numberFormat: NumberFormat("###.##", "en_US"),
                                  maximumLabelWidth: 25),
                              legend: Legend(isVisible: false),
                              // Enable tooltip
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <ChartSeries<_Data, DateTime>>[
                                LineSeries<_Data, DateTime>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      // Assigning the controller to the _chartSeriesController.
                                      _chartSeriesController4 = controller;
                                    },
                                    dataSource: lastestData,
                                    xValueMapper: (_Data test, _) =>
                                        test.timestamp,
                                    yValueMapper: (_Data test, _) =>
                                        test.visible_light,
                                    name: 'Visible Light',
                                    // Enable data label
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: false)),
                              ]),
                        ],
                      );
                    }
                    return CircularProgressIndicator();
                  }),
            ])));
  }
}

const loremIpsum = "";

class Card1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "ExpandablePanel",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: Text(
                  loremIpsum,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var _ in Iterable.generate(5))
                      Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            loremIpsum,
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          )),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class Card2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    buildImg(Color color, double height) {
      return SizedBox(
          height: height,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
            ),
          ));
    }

    buildCollapsed1() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Expandable",
                    style: Theme.of(context).textTheme.body1,
                  ),
                ],
              ),
            ),
          ]);
    }

    buildCollapsed2() {
      return buildImg(Colors.lightGreenAccent, 150);
    }

    buildCollapsed3() {
      return Container();
    }

    buildExpanded1() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Expandable",
                    style: Theme.of(context).textTheme.body1,
                  ),
                  Text(
                    "3 Expandable widgets",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ]);
    }

    buildExpanded2() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: buildImg(Colors.lightGreenAccent, 100)),
              Expanded(child: buildImg(Colors.orange, 100)),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: buildImg(Colors.lightBlue, 100)),
              Expanded(child: buildImg(Colors.cyan, 100)),
            ],
          ),
        ],
      );
    }

    buildExpanded3() {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              loremIpsum,
              softWrap: true,
            ),
          ],
        ),
      );
    }

    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expandable(
                collapsed: buildCollapsed1(),
                expanded: buildExpanded1(),
              ),
              Expandable(
                collapsed: buildCollapsed2(),
                expanded: buildExpanded2(),
              ),
              Expandable(
                collapsed: buildCollapsed3(),
                expanded: buildExpanded3(),
              ),
              Divider(
                height: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      var controller =
                          ExpandableController.of(context, required: true);
                      return TextButton(
                        child: Text(
                          controller.expanded ? "COLLAPSE" : "EXPAND",
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.deepPurple),
                        ),
                        onPressed: () {
                          controller.toggle();
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class Card3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    buildItem(String label) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(label),
      );
    }

    buildList() {
      return Column(
        children: <Widget>[
          for (var i in [1, 2, 3, 4]) buildItem("Item ${i}"),
        ],
      );
    }

    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToExpand: true,
                  tapBodyToCollapse: true,
                  hasIcon: false,
                ),
                header: Container(
                  color: Colors.indigoAccent,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ExpandableIcon(
                          theme: const ExpandableThemeData(
                            expandIcon: Icons.arrow_right,
                            collapseIcon: Icons.arrow_drop_down,
                            iconColor: Colors.white,
                            iconSize: 28.0,
                            iconRotationAngle: math.pi / 2,
                            iconPadding: EdgeInsets.only(right: 5),
                            hasIcon: false,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Items",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                collapsed: Container(),
                expanded: buildList(),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
