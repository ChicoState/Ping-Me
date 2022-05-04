
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingme/request.dart';

class FireStoreDataBase {
  List friendList = [];
  List requestList = [];
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection("userEmails");

  Future getData() async {//generates snapshot of friends list
    try {
        var firebaseUser = FirebaseAuth.instance.currentUser;
        if(firebaseUser != null) {
          await collectionRef.doc(firebaseUser.uid).collection("friends").get().then((querySnapshot) {
            for (var result in querySnapshot.docs) {
              friendList.add(result.data());
            }
          });
              }
      return friendList;
    } catch(e) {
      debugPrint("Error - $e");
      return null;
    }
  }
}

// FRIENDS PAGE CLASS
class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List friendsList2 = [];
  var firebaseUser = FirebaseAuth.instance.currentUser;
  final emailController = TextEditingController();
  bool _incompleteForm = false;
  bool _friendDoesNotExist = false;
  String friendUID = '';
  String username = '';
  // FRIEND LIST ENTRY WIDGET FUNCTION
  bool _switch = false;
  Widget friendEntry(String entry) => SwitchListTile(
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
        title: const Text('My Friends'),
        centerTitle: true,
          actions: [IconButton(
            //settings button
            icon: const Icon(Icons.add_reaction),
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RequestPage())).then((_){
                        setState(() {

                        });
              });
            },
          )]
      ),
      body: FutureBuilder(
        future: FireStoreDataBase().getData(),
        builder:(context, snapshot){
          if(snapshot.hasError){
            return const Text("something went wrong",);
          }
          if(snapshot.connectionState == ConnectionState.done) {
            friendsList2 = snapshot.data as List;
            return buildItems(friendsList2);
          }
          return const Center(child: CircularProgressIndicator());
        }
        ),



      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: const Text('Add Friend'),
                  content: TextField(
                    controller: emailController,
                    textAlign: TextAlign.center,
                    decoration:
                    const InputDecoration(labelText: 'Enter a Username'),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    // ADD FRIEND BUTTON
                    TextButton(
                        onPressed: () async {
                          // First getting the friend UID to confirm it's existance
                          _incompleteForm = emailController.text == '';
                          if (!_incompleteForm) {
                            await FirebaseFirestore.instance
                                .collection('userEmails')
                                .where("username", isEqualTo: emailController.text)
                                .get()
                                .then((querySnapshot) {
                              friendUID = querySnapshot.docs[0].id;
                            });
                          }
                          _friendDoesNotExist =
                              friendUID == 'null' || friendUID == '';
                          // Friend exists so now we add em
                          if (!_friendDoesNotExist) {
           var firebaseUser = FirebaseAuth.instance.currentUser;

              if(firebaseUser != null) {
                await FirebaseFirestore.instance.collection('userEmails').doc(firebaseUser.uid)
                    .get().then((res) {
                   username = res['username'].toString();
                });
                await FirebaseFirestore.instance
                      .collection('userEmails')
                      .doc(friendUID).collection("requests")
                      .doc(firebaseUser.uid).set({
                      // Appending to field array

                        "username" : username,
                        "accept" : false,
                      });
          }
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        child: const Text('Ok'))
                  ]));
        },
      ),
      );
  }
  Widget buildItems(friendsList2) => ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: friendsList2.length,
    separatorBuilder: (BuildContext context, int index) => const Divider(),
    itemBuilder: (BuildContext context, int index) {
      return SwitchListTile(

        title: Text(friendsList2[index]["username"],),
        value: friendsList2[index]["tracking"],
        onChanged: (bool value){
          setState(() {
            var firebaseUser = FirebaseAuth.instance.currentUser;
            if(firebaseUser != null){
              FirebaseFirestore.instance
                  .collection('userEmails')
                  .where("username", isEqualTo: friendsList2[index]["username"])
                  .get()
                  .then((querySnapshot) {
                friendUID = querySnapshot.docs[0].id;
              });
              FirebaseFirestore.instance.collection("userEmails").doc(friendUID).get().then((res){
                FirebaseFirestore.instance.collection("userEmails").doc(firebaseUser.uid).collection("friends").doc(friendUID).set({
                  "tracking": value,
                  "username":friendsList2[index]["username"],
                  "location":res["location"],
                  "time":res["time"],
                });
              });
              FirebaseFirestore.instance.collection("userEmails").doc(firebaseUser.uid).collection("friends").where("username", isEqualTo: friendsList2[index]["username"]).get().then((res) {
                final results = res.docs[0].id;
                FirebaseFirestore.instance.collection("userEmails").doc(firebaseUser.uid).collection("friends").doc(results).update({"tracking" : value});
                setState(() {});
              });
            }

          });
        }
      );
    });
}
