
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//firestore class


class FireStoreDataBase {
  List friendList = [];
  final CollectionReference collectionRef =
      FirebaseFirestore.instance.collection("userEmails");

  Future getData() async {
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
  final emailController = TextEditingController();
  bool _incompleteForm = false;
  bool _friendDoesNotExist = false;
  String friendUID = '';
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
                await FirebaseFirestore.instance
                      .collection('userEmails')
                      .doc(firebaseUser.uid).collection("friends")
                      .doc(friendUID).set({
                      // Appending to field array

                        "username" : emailController.text,
                        "tracking" : false,
                      });
          }
                            Navigator.pop(context);
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
