import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireStoreDataBase {
  List requestList = [];
  final CollectionReference collectionRef =
  FirebaseFirestore.instance.collection("userEmails");

  Future getData() async {//generates snapshot of friends list
    try {
      var firebaseUser = FirebaseAuth.instance.currentUser;
      if(firebaseUser != null) {
        await collectionRef.doc(firebaseUser.uid).collection("requests").get().then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            requestList.add(result.data());
          }
        });
      }
      return requestList;
    } catch(e) {
      debugPrint("Error - $e");
      return null;
    }
  }
}

// FRIENDS PAGE CLASS
class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);
  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List requestList2 = [];
  var firebaseUser = FirebaseAuth.instance.currentUser;
  final emailController = TextEditingController();
  String friendUID = '';
  String username = '';
  // FRIEND LIST ENTRY WIDGET FUNCTION
  bool _switch = false;
  Widget requestEntry(String entry) => SwitchListTile(
    title: Text(entry, style: const TextStyle(color: Colors.black)),
    value: _switch,
    onChanged: (bool value) {
      setState(() {
        _switch = value;
      });
    },
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: const Text('Friend Requests'),
          centerTitle: true,
      ),
      body: FutureBuilder(
          future: FireStoreDataBase().getData(),
          builder:(context, snapshot){
            if(snapshot.hasError){
              return const Text("something went wrong",);
            }
            if(snapshot.connectionState == ConnectionState.done) {
              requestList2 = snapshot.data as List;
              return buildItems(requestList2);
            }
            return const Center(child: CircularProgressIndicator());
          }
      ),

    );
  }

  Widget buildItems(requestList2) => ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: requestList2.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        return SwitchListTile(

            title: Text(requestList2[index]["username"],),
            subtitle: Text('accept'),
            value: requestList2[index]["accept"],
            onChanged: (bool value){
              setState(() {
                var firebaseUser = FirebaseAuth.instance.currentUser;
                if(firebaseUser != null){
                  FirebaseFirestore.instance.collection("userEmails").doc(firebaseUser.uid).collection("requests").where("username", isEqualTo: requestList2[index]["username"]).get().then((res) {
                    final results = res.docs[0].id;
                    FirebaseFirestore.instance.collection("userEmails").doc(firebaseUser.uid).collection("friends").doc(results).set({
                      "username":requestList2[index]["username"],
                      "tracking": false,

                    });
                    FirebaseFirestore.instance.collection("userEmails").doc(firebaseUser.uid).collection("requests").doc(results).delete();
                  });

                }

              });
            }
        );
      });
}
