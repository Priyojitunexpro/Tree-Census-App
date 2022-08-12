import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treesensus/database/auth.dart';
import 'package:treesensus/models/tree.dart';

class DatabaseMethods {
  static final firestore = FirebaseFirestore.instance;

  Stream<List<Tree>> getAllTrees() {
    print("[INFO] Getting all the trees from the database.");
    String path = "Trees/";
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();
    print(snapshots.map((snapshot) =>
        snapshot.docs.map((doc) => Tree.fromMap(doc.data())).toList()));
    return snapshots.map((snapshot) =>
        snapshot.docs.map((doc) => Tree.fromMap(doc.data())).toList());
  }

  Future<int> getTreesCount() async {
    return await firestore
        .collection("Trees")
        .get()
        .then((value) => value.docs.length);
  }

  Future<void> updateGraphData(Map<String, dynamic> data) async {
    await firestore.collection("graphData").doc("1").update(data);
  }

  Future<void> addTreeData(Tree tree, String uid, int count) async {
    try {
      print("[INFO] Storing new tree details");

      await firestore.collection("Trees").doc(tree.treeId).set(tree.toMap());
      await firestore
          .collection("Users")
          .doc(uid)
          .update({'totalTrees': count += 1});
      print("[INFO] Stored new tree details");
    } on FirebaseException catch (e) {
      print("[ERROR] ${e.message}");
      throw FirebaseException(
        message: e.message,
        plugin: e.plugin,
        code: e.code,
      );
    } catch (e) {
      print("[ERROR] ${e.toString()}");
      throw e.toString();
    }
  }

  Future<bool> checkUser(String uid) async {
    var data = await firestore
        .collection("Users")
        .where('uid', isEqualTo: uid)
        .get()
        .then((data) => data.docs);
    print(data);
    if (data.length != 0) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    Map<String, dynamic>? data = await firestore
        .collection("Users")
        .doc(uid)
        .get()
        .then((doc) => doc.data());
    return data;
  }

  Future<Map<String, dynamic>?> getGraph() async {
    Map<String, dynamic>? data = await firestore
        .collection("graphData")
        .doc("1")
        .get()
        .then((doc) => doc.data());
    return data;
  }

  Future<void> addUserData(UserClass user) async {
    try {
      print("[INFO] Storing new User details");
      await firestore.collection("Users").doc(user.uid).set(user.toMap());
      print("[INFO] Stored new User details");
    } on FirebaseException catch (e) {
      print("[ERROR] ${e.message}");
      throw FirebaseException(
        message: e.message,
        plugin: e.plugin,
        code: e.code,
      );
    } catch (e) {
      print("[ERROR] ${e.toString()}");
      throw e.toString();
    }
  }

  Future<void> deleteTreeData(String treeId, String uid, int count) async {
    try {
      print("[INFO] Deleting Tree with ID: $treeId ");

      await firestore.collection("Trees").doc(treeId).delete();
      await firestore
          .collection("Users")
          .doc(uid)
          .update({'totalTrees': count -= 1});
      print("[INFO] Deleted Tree with ID: $treeId ");
    } on FirebaseException catch (e) {
      print("[ERROR] ${e.message}");
      throw FirebaseException(
        message: e.message,
        plugin: e.plugin,
        code: e.code,
      );
    } catch (e) {
      print("[ERROR] ${e.toString()}");
      throw e.toString();
    }
  }

  Future<void> updateTreeData(
      String treeId, Map<String, dynamic> updatedData) async {
    try {
      print("[INFO] Deleting Tree with ID: $treeId ");
      await firestore.collection("Trees").doc(treeId).update(updatedData);
      print("[INFO] Deleted Tree with ID: $treeId ");
    } on FirebaseException catch (e) {
      print("[ERROR] ${e.message}");
      throw FirebaseException(
        message: e.message,
        plugin: e.plugin,
        code: e.code,
      );
    } catch (e) {
      print("[ERROR] ${e.toString()}");
      throw e.toString();
    }
  }
}
