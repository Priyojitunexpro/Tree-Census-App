import 'package:flutter/material.dart';
import 'package:treesensus/dashboard.dart';
import 'package:treesensus/database/auth.dart';
import 'package:treesensus/database/database.dart';
import 'package:treesensus/login_page.dart';
import 'package:treesensus/tree_form.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class OwnerType {
  OwnerType({required this.count, required this.type});
  String type;
  int count;
}

class Height {
  Height({required this.count, required this.type});
  String type;
  int count;
}

class TreeHealth {
  TreeHealth({required this.health, required this.count});
  String health;
  int count;
}

class HomePage extends StatefulWidget {
  final UserClass user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseMethods _db = DatabaseMethods();
  int count = 0;
  int public = 0;
  int private = 0;
  late UserClass userData;
  bool dataFetching = true;
  List<OwnerType> ownerGraph = [];
  List<TreeHealth> healthGraph = [];
  List<Height> heightGraph = [];
  Map<String, dynamic> gData = {};
  late TooltipBehavior _toolTipBehaviour;
  @override
  void initState() {
    // TODO: implement initState
    _toolTipBehaviour = TooltipBehavior(enable: true);
    super.initState();
    getTreeCountandUserData();
  }

  getTreeCountandUserData() async {
    int trees = await _db.getTreesCount();
    Map<String, dynamic>? uData = await _db.getUser(widget.user.uid);
    Map<String, dynamic>? gD = await _db.getGraph();
    UserClass user = UserClass.fromMap(uData!);
    List<OwnerType> d = [
      OwnerType(count: gD!['public'], type: 'public'),
      OwnerType(count: gD['private'], type: 'private')
    ];
    List<TreeHealth> th = [
      TreeHealth(count: gD['Infected'], health: 'Infected'),
      TreeHealth(count: gD['Dried'], health: 'Dried'),
      TreeHealth(count: gD['Pale'], health: 'Pale'),
      TreeHealth(count: gD['Green'], health: 'Green')
    ];
    List<Height> hei = [
      Height(count: gD['height']['0-5ft'], type: '0-5ft'),
      Height(count: gD['height']['5-10ft'], type: '5-10ft'),
      Height(count: gD['height']['10-15ft'], type: '10-15ft'),
      Height(count: gD['height']['15-20ft'], type: '15-20ft'),
      Height(count: gD['height']['20-25ft'], type: '20-25ft'),
      Height(count: gD['height']['25-30ft'], type: '25-30ft'),
      Height(count: gD['height']['30-35ft'], type: '30-35ft'),
      Height(count: gD['height']['35-40ft'], type: '35-40ft'),
      Height(count: gD['height']['40-45ft'], type: '40-45ft'),
      Height(count: gD['height']['45-50ft'], type: '45-50ft'),
      Height(count: gD['height']['50-55ft'], type: '50-55ft'),
      Height(count: gD['height']['55-60ft'], type: '55-60ft'),
      Height(count: gD['height']['60ft and above'], type: '60ft and above'),
    ];
    setState(() {
      heightGraph = hei;
      gData = gD;
      healthGraph = th;
      ownerGraph = d;
      userData = user;
      count = trees;
      dataFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF3EAD44),
        actions: [
          TextButton.icon(
              onPressed: getTreeCountandUserData,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label:
                  const Text('Refresh', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(15),
              width: width,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 1.5,
                color: Colors.green[50],
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Tree Count: ",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.green),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              width: width,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 1.5,
                color: Colors.green[50],
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Trees tagged by you: ",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.green),
                      ),
                      // ignore: unnecessary_null_comparison
                      dataFetching == true
                          ? const Text(
                              '-',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : Text(
                              '${userData.totalTrees}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            dataFetching == false
                ? Container(
                    margin: EdgeInsets.all(15),
                    child: SfCircularChart(
                      title: ChartTitle(text: 'Tree counts by owner type'),
                      tooltipBehavior: _toolTipBehaviour,
                      legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap),
                      series: <CircularSeries>[
                        PieSeries<OwnerType, String>(
                          dataSource: ownerGraph,
                          xValueMapper: (OwnerType data, _) => data.type,
                          yValueMapper: (OwnerType data, _) => data.count,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          enableTooltip: true,
                        )
                      ],
                    ))
                : Container(),
            dataFetching == false
                ? Container(
                    margin: EdgeInsets.all(15),
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                          title: AxisTitle(
                        text: 'Tree Health',
                      )),
                      primaryYAxis: NumericAxis(
                          title: AxisTitle(
                        text: 'Freuency',
                      )),
                      title: ChartTitle(text: 'Trees Distinguished by Health'),
                      series: <ChartSeries>[
                        ColumnSeries<TreeHealth, String>(
                          dataSource: healthGraph,
                          xValueMapper: (TreeHealth data, _) => data.health,
                          yValueMapper: (TreeHealth data, _) => data.count,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        )
                      ],
                    ))
                : Container(),
            dataFetching == false
                ? Container(
                    margin: EdgeInsets.all(15),
                    child: SfCircularChart(
                      title: ChartTitle(text: 'Tree counts by height'),
                      tooltipBehavior: _toolTipBehaviour,
                      legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap),
                      series: <CircularSeries>[
                        DoughnutSeries<Height, String>(
                          dataSource: heightGraph,
                          xValueMapper: (Height data, _) => data.type,
                          yValueMapper: (Height data, _) => data.count,
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                          enableTooltip: true,
                        )
                      ],
                    ))
                : Container(),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.green[800]),
                accountName: Text(widget.user.displayName.toString()),
                accountEmail: Text(widget.user.email.toString()),
                currentAccountPicture: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage("${widget.user.photoUrl}"),
                  backgroundColor: Colors.transparent,
                )),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text(
                'Map',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Dashboard(
                          user: userData,
                          graph: gData,
                        )));
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.info_outlined),
              title: const Text(
                'Tree Form',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        TreeForm(user: userData, graph: gData)));
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () async {
                await Auth().signOutFromGoogle();
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
