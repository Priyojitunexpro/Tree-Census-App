import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:searchfield/searchfield.dart';
import 'package:treesensus/database/auth.dart';
import 'package:treesensus/database/database.dart';
import 'package:treesensus/models/tree.dart';
import 'package:treesensus/widgets/custom_form_field.dart';
import 'package:treesensus/widgets/custom_validator.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';

class TreeInfoDisplay extends StatefulWidget {
  final Tree tree;
  final UserClass user;
  Map<String, dynamic> graph;
  TreeInfoDisplay(
      {required this.tree, required this.user, required this.graph});

  @override
  State<TreeInfoDisplay> createState() => _TreeInfoDisplayState();
}

class _TreeInfoDisplayState extends State<TreeInfoDisplay> {
  String _lat = '';
  String _long = '';
  String _landmark = "";
  String _height = "Select";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool isSubmitted = false;
  bool load = true;
  String diameter = "Select";
  String treeHealth = "Select";
  String harmfulPrac = "Select";
  String ownerType = "Select";
  String _date = "";
  String botanical = "";
  String loc = "";
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

  _loadAsset() async {
    var jsonText = await rootBundle.loadString('assets/trees.json');
    var jsonResult = json.decode(jsonText);
    for (int i = 0; i < jsonResult.length; i++) {
      bot.add(jsonResult[i]['botanical'].toString());
      local.add(jsonResult[i]['local'].toString());
    }
    print(bot.length);
    print(local.length);
    print(local.contains(widget.tree.local));
    setState(() {
      load = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lat = widget.tree.latitude;
    _long = widget.tree.longitude;
    _landmark = widget.tree.landmark;
    _height = widget.tree.height;
    _date = widget.tree.date;
    treeHealth = widget.tree.health;
    harmfulPrac = widget.tree.harmPrac;
    ownerType = widget.tree.ownerType;
    diameter = widget.tree.diameter;
    loc = widget.tree.local;
    botanical = widget.tree.botanical;
    _botController.text = widget.tree.botanical;
    _loadAsset();
  }

  void _deleteTree(BuildContext context2) async {
    print("Deleting...........................");
    var confirmation = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Do you want to delete this tree?'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "true");
                },
                child: Text("Yes"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, "false");
                },
                child: Text("No"),
              ),
            ],
          );
        });
    print("Confirmation = $confirmation");
    if (confirmation == "true") {
      try {
        DatabaseMethods db = DatabaseMethods();
        print(widget.graph);
        setState(() {
          isSubmitted = false;
          widget.graph[ownerType.toLowerCase()] -= 1;
          widget.graph['height'][_height] -= 1;
          widget.graph[treeHealth] -= 1;
        });
        print(widget.graph);
        await db.updateGraphData(widget.graph);
        await db.deleteTreeData(
            widget.tree.treeId, widget.user.uid, widget.user.totalTrees);
        Navigator.of(context2).pop();
      } on FirebaseException catch (e) {
        print(e.toString());
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tree Information'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: load == true
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.green[800],
                ),
              )
            : Stack(
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
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(20),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFormField(
                            onChanged: (val) {
                              setState(() {
                                _date = val;
                              });
                              print(_date);
                            },
                            labelText: "Date",
                            initialValue: _date,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomFormField(
                            onChanged: (val) {
                              setState(() {
                                _landmark = val;
                              });
                              print(_landmark);
                            },
                            labelText: "Landmark",
                            initialValue: _landmark,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomFormField(
                            onChanged: (val) {
                              setState(() {
                                _long = val;
                              });
                              print(_long);
                            },
                            labelText: "Longitude",
                            initialValue: _lat,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          CustomFormField(
                            onChanged: (val) {
                              setState(() {
                                _lat = val;
                              });
                              print(_lat);
                            },
                            labelText: "Latitude",
                            initialValue: _lat,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(15),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Height",
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
                                HeightValidator(),
                              ]),
                              hint: const Text("Select height"),
                              value: _height,
                              elevation: 0,
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
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.all(15),
                            child: SearchField(
                              initialValue:
                                  SearchFieldListItem<String>(loc, item: loc),
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
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
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
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
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
                            padding: EdgeInsets.all(15),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Diameter",
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
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
                                  child: new Text(fname),
                                  value: fname,
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(15),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Owner Type",
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
                                HeightValidator(),
                              ]),
                              hint: const Text("Select Owner Type"),
                              value: ownerType,
                              elevation: 0,
                              isExpanded: true,
                              style: const TextStyle(
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
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(15),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Tree Health",
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
                                HeightValidator(),
                              ]),
                              hint: const Text("Select tree health"),
                              value: treeHealth,
                              elevation: 0,
                              isExpanded: true,
                              style: const TextStyle(
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
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: EdgeInsets.all(15),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: "Harmful Practices",
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                              ),
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Cannot Be Empty"),
                                HeightValidator(),
                              ]),
                              hint: const Text("Select harmful practices"),
                              value: harmfulPrac,
                              elevation: 0,
                              isExpanded: true,
                              style: const TextStyle(
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
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(15),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blueGrey[700]),
                                  textStyle: MaterialStateProperty.all(
                                    const TextStyle(fontSize: 20),
                                  ),
                                ),
                                child: const Text(
                                  'Update Tree',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () => _submit(context),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(15),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.red[700]),
                                  textStyle: MaterialStateProperty.all(
                                    const TextStyle(fontSize: 20),
                                  ),
                                ),
                                child: const Text(
                                  'Delete Tree',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () => _deleteTree(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          treeId: widget.tree.treeId,
          height: _height,
          latitude: _lat,
          longitude: _long,
          landmark: _landmark,
          date: _date,
          diameter: diameter,
          harmPrac: harmfulPrac,
          health: treeHealth,
          ownerType: ownerType,
          local: loc,
          botanical: botanical,
        );

        DatabaseMethods db = DatabaseMethods();
        print(widget.graph);
        setState(() {
          if (ownerType.toLowerCase() != widget.tree.ownerType.toLowerCase()) {
            widget.graph[ownerType.toLowerCase()] += 1;
            widget.graph[widget.tree.ownerType.toLowerCase()] -= 1;
          }
          if (_height.toLowerCase() != widget.tree.height.toLowerCase()) {
            widget.graph['height'][_height] += 1;
            widget.graph['height'][widget.tree.height] -= 1;
          }
          if (treeHealth.toLowerCase() != widget.tree.health.toLowerCase()) {
            widget.graph[treeHealth] += 1;
            widget.graph[widget.tree.health] -= 1;
          }
        });
        print(widget.graph);
        await db.updateGraphData(widget.graph);
        await db.updateTreeData(widget.tree.treeId, treeData.toMap());
        setState(() {
          isSubmitted = false;
        });
        Navigator.pop(context, "updated");
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
