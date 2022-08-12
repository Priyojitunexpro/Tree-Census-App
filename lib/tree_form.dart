import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:treesensus/database/database.dart';
import 'package:treesensus/models/tree.dart';
import 'package:treesensus/widgets/custom_form_field.dart';
import 'package:treesensus/widgets/custom_validator.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'package:searchfield/searchfield.dart';
import 'database/auth.dart';

enum PermissionGroup {
  locationAlways,
}

class TreeForm extends StatefulWidget {
  final UserClass user;
  final Map<String, dynamic> graph;
  const TreeForm({Key? key, required this.user, required this.graph})
      : super(key: key);

  @override
  _TreeFormState createState() => _TreeFormState();
}

class _TreeFormState extends State<TreeForm> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool locationFetched = false;
  bool isSubmitted = false;
  late Position _currentPosition;
  String _lat = "00.00000";
  String _long = "00.00000";
  String _latlong = "00.00000";
  String _landmark = "";
  String address = "";
  String _height = "Select";
  String diameter = "Select";
  String treeHealth = "Select";
  String harmfulPrac = "Select";
  String ownerType = "Select";
  String botanical = "";
  String loc = "";
  String _date = "";
  List<String> bot = [];
  List<String> local = [];
  final TextEditingController _botController = TextEditingController(text: "");

  List<String> healths = ["Select", "Infected", "Dried", "Pale", "Green"];
  List<String> practices = [
    "Select",
    "Nails",
    "Boards",
    "Cut Marks",
    "Cemented or paved",
    "Anyother"
  ];
  List<String> owners = ["Select", "Public", "Private"];
  final List<String> _heightRanges = [
    "Select",
    '0-5ft',
    '5-10ft',
    '10-15ft',
    '15-20ft',
    '20-25ft',
    '25-30ft',
    '30-35ft',
    '35-40ft',
    '40-45ft',
    '45-55ft',
    '55-60ft',
    '60ft and above'
  ];

  final List<String> _diameterRanges = [
    "Select",
    '0-1ft',
    '1-2ft',
    '2-3ft',
    '3-4ft',
    '4-5ft',
    '5ft and more'
  ];

  bool validateForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  void extractLatLong() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        // return Future.error('Location services are disabled.');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      // print(placemarks);
      Placemark place = placemarks[0];
      String add =
          '${place.street}, ${place.thoroughfare}, ${place.subLocality}';
      print(add);
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(now);
      print(formatted);
      var jsonText = await rootBundle.loadString('assets/trees.json');
      var jsonResult = json.decode(jsonText);
      for (int i = 0; i < jsonResult.length; i++) {
        bot.add(jsonResult[i]['ï»¿botanical'].toString());
        local.add(jsonResult[i]['local'].toString());
      }
      print(bot.length);
      print(local.length);
      setState(() {
        _date = formatted;
        _landmark = add;
        _lat = _currentPosition.latitude.toString();
        _long = _currentPosition.longitude.toString();
        locationFetched = true;
      });
    } catch (e) {
      print("Error ${e.toString()}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    extractLatLong();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tree Tagging Form'),
        backgroundColor: const Color(0xFF3EAD44),
      ),
      body: locationFetched == false
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green[900],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                child: Stack(
                  children: [
                    isSubmitted == true
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.green[800],
                              ),
                            ),
                          )
                        : Form(
                            key: _formKey,
                            autovalidateMode: _autovalidateMode,
                            child: Column(
                              children: [
                                CustomFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _date = val;
                                    });
                                    print(_date);
                                  },
                                  labelText: "Date",
                                  initialValue: locationFetched == false
                                      ? 'Fetching Date....'
                                      : _date,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _landmark = val;
                                    });
                                    print(_landmark);
                                  },
                                  labelText: "Landmark",
                                  initialValue: locationFetched == false
                                      ? 'Fetching Landmark....'
                                      : _landmark,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _lat = val;
                                    });
                                    print(_lat);
                                  },
                                  labelText: "Latitude",
                                  initialValue: locationFetched == false
                                      ? 'Fetching Latitude....'
                                      : _lat,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CustomFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _long = val;
                                    });
                                    print(_long);
                                  },
                                  labelText: "Longitude",
                                  initialValue: locationFetched == false
                                      ? 'Fetching Longitude....'
                                      : _long,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Colors.green[50],
                                    decoration: InputDecoration(
                                      labelText: "Height",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                      HeightValidator(),
                                    ]),
                                    hint: const Text("Select height"),
                                    value: _height,
                                    elevation: 1,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        _height = val.toString();
                                      });
                                    },
                                    items: _heightRanges.map((fname) {
                                      return DropdownMenuItem(
                                        child: new Text(fname),
                                        value: fname,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: SearchField(
                                    suggestionAction: SuggestionAction.unfocus,
                                    suggestions: local
                                        .map(
                                          (e) => SearchFieldListItem<String>(
                                            e,
                                            item: e,
                                          ),
                                        )
                                        .toList(),
                                    searchInputDecoration: InputDecoration(
                                      labelText: "Local Name",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                    ]),
                                    onTap: (val) {
                                      print(val.item);
                                      setState(() {
                                        loc = val.item.toString();
                                      });
                                      bool check = local.contains(val.item);
                                      print(check);
                                      if (check == true) {
                                        print("contains");
                                        int index =
                                            local.indexOf(val.item.toString());
                                        setState(() {
                                          _botController.text = bot[index];
                                          botanical = bot[index];
                                        });
                                        print(botanical);
                                      }
                                    },
                                    maxSuggestionsInViewPort: 6,
                                    itemHeight: 50,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: TextFormField(
                                    controller: _botController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      labelText: "Botanical Name",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                    ]),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        botanical = val.toString();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Colors.green[50],
                                    decoration: InputDecoration(
                                      labelText: "Diameter",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                      HeightValidator(),
                                    ]),
                                    hint: const Text("Select Diameter"),
                                    value: diameter,
                                    elevation: 0,
                                    isExpanded: true,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        diameter = val.toString();
                                      });
                                    },
                                    items: _diameterRanges.map((fname) {
                                      return DropdownMenuItem(
                                        child: Text(fname),
                                        value: fname,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.all(15),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Colors.green[50],
                                    decoration: InputDecoration(
                                      labelText: "Ownership Type",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                      HeightValidator(),
                                    ]),
                                    hint: const Text("Select Owner Type"),
                                    value: ownerType,
                                    elevation: 0,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        ownerType = val.toString();
                                      });
                                    },
                                    items: owners.map((fname) {
                                      return DropdownMenuItem(
                                        child: new Text(fname),
                                        value: fname,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.all(15),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Colors.green[50],
                                    decoration: InputDecoration(
                                      labelText: "Tree Health",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                      HeightValidator(),
                                    ]),
                                    hint: const Text("Select tree health"),
                                    value: treeHealth,
                                    elevation: 0,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        treeHealth = val.toString();
                                      });
                                    },
                                    items: healths.map((fname) {
                                      return DropdownMenuItem(
                                        child: new Text(fname),
                                        value: fname,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.all(15),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Colors.green[50],
                                    decoration: InputDecoration(
                                      labelText: "Harmful Practices",
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "Cannot Be Empty"),
                                      HeightValidator(),
                                    ]),
                                    hint:
                                        const Text("Select harmful practices"),
                                    value: harmfulPrac,
                                    elevation: 0,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        harmfulPrac = val.toString();
                                      });
                                    },
                                    items: practices.map((fname) {
                                      return DropdownMenuItem(
                                        child: new Text(fname),
                                        value: fname,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        elevation:
                                            MaterialStateProperty.all(15),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.green[700]),
                                        textStyle: MaterialStateProperty.all(
                                          const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      child: const Text(
                                        'Submit',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () => _submit(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  void _submit(BuildContext context) async {
    try {
      setState(() {
        isSubmitted = true;
      });
      if (validateForm()) {
        print("Submitting");
        print(_lat);
        print(_long);
        print(_height);
        print(_landmark);

        Tree treeData = Tree(
          treeId: 'tree_${DateTime.now().toIso8601String()}',
          height: _height,
          latitude: _lat,
          longitude: _long,
          landmark: _landmark,
          date: _date,
          diameter: diameter,
          harmPrac: harmfulPrac,
          health: treeHealth,
          ownerType: ownerType,
          botanical: _botController.text,
          local: loc,
        );

        DatabaseMethods db = DatabaseMethods();

        await db.addTreeData(treeData, widget.user.uid, widget.user.totalTrees);
        // setState(() {
        //   widget.graph[ownerType] += 1;
        // });
        // await db.updateGraphData(widget.graph);
        print(widget.graph);
        setState(() {
          isSubmitted = false;
          widget.graph[ownerType.toLowerCase()] += 1;
          widget.graph['height'][_height] += 1;
          widget.graph[treeHealth] += 1;
        });
        print(widget.graph);
        await db.updateGraphData(widget.graph);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _autovalidateMode = AutovalidateMode.always;
          isSubmitted = false;
        });
      }
    } on FirebaseException catch (e) {
      print(e.toString());
      setState(() {
        isSubmitted = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        isSubmitted = false;
      });
    }
  }
}
