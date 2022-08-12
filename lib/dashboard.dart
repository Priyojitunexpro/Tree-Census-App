import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treesensus/database/auth.dart';
import 'package:treesensus/database/database.dart';
import 'package:treesensus/tree_info_display.dart';

class Dashboard extends StatefulWidget {
  final UserClass user;
  Map<String, dynamic> graph;
  Dashboard({Key? key, required this.user, required this.graph})
      : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late BitmapDescriptor pinLocationIcon;
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(19.7515, 75.7139), zoom: 8);

  // GoogleMapController _controller;
  List<Marker> markers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initializeMarkers();
    setCustomMapPin();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(12, 12)), 'assets/images/t_icon.png')
        .then((d) {
      pinLocationIcon = d;
    });
  }

  void setCustomMapPin() async {
    BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(2, 2)), 'assets/images/t_icon.png');
    setState(() {
      pinLocationIcon = icon;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void initializeMarkers() async {
    Marker first = Marker(
      markerId: MarkerId("1"),
      position: LatLng(19.7515, 75.7139),
      infoWindow: InfoWindow(title: 'Ghatkopar'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      markers.add(first);
    });
  }

  void onGoBack() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: StreamBuilder<List>(
          stream: DatabaseMethods().getAllTrees(),
          builder: (context, snapshot) {
            print("1===================================================");
            print(snapshot.connectionState);
            print(snapshot.hasData);
            if (snapshot.connectionState == ConnectionState.active) {
              print("2===================================================");
              if (snapshot.hasData) {
                print("3===================================================");
                List<Marker> markers = [];
                List? data = snapshot.data;
                print("4===================================================");
                print(data);
                print(data!.length);
                print("5===================================================");
                for (int i = 0; i < data.length; i++) {
                  Marker first = Marker(
                      markerId: MarkerId(data[i].treeId),
                      position: LatLng(double.parse(data[i].latitude),
                          double.parse(data[i].longitude)),
                      infoWindow:
                          InfoWindow(title: 'Landmark: ${data[i].landmark}'),
                      icon: pinLocationIcon,
                      onTap: () {
                        print("Displaying Tree Info");
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => TreeInfoDisplay(
                                      tree: data[i],
                                      user: widget.user,
                                      graph: widget.graph,
                                    )))
                            .then((value) {
                          if (value == "updated") {
                            onGoBack();
                          }
                        });
                      });
                  // setState(() {
                  markers.add(first);
                  // });
                }
                return Container(
                  child: GoogleMap(
                    zoomControlsEnabled: true,
                    initialCameraPosition: _initialCameraPosition,
                    markers: markers.map((e) => e).toSet(),
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                  Container(
                    child: const GoogleMap(
                      zoomControlsEnabled: false,
                      initialCameraPosition: _initialCameraPosition,
                    ),
                  ),
                ],
              );
            }
            return const GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
            );
          }),
    );
  }
}
