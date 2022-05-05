import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingme/requests.dart';

// FRIENDS PAGE CLASS
class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late var friendsDocs;
  final emailController = TextEditingController();
  bool _incompleteForm = false;
  bool _friendDoesNotExist = false;
  String username = '';
  String friendUID = '';
  final _uid = FirebaseAuth.instance.currentUser!.uid;

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
        title: const Text('PingMates'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FriendsRequests()));
              },
              icon: const Icon(Icons.group_add))
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('userEmails')
              .doc(_uid)
              .collection('friends')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                "something went wrong",
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // BUILDING FRIENDS LIST
            if (snapshot.hasData) {
              friendsDocs = snapshot.data?.docs;
              return ListView.separated(
                  itemCount: friendsDocs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    // FRIEND TILE
                    return SwitchListTile(
                        title: Text(friendsDocs[index]['username']),
                        value: friendsDocs[index]['tracking'],
                        onChanged: (value) {
                          FirebaseFirestore.instance
                              .collection('userEmails')
                              .doc(_uid)
                              .collection("friends")
                              .where('uid',
                                  isEqualTo: friendsDocs[index]['uid'])
                              .get()
                              .then((res) {
                            final results = res.docs[0].id;
                            FirebaseFirestore.instance
                                .collection("userEmails")
                                .doc(_uid)
                                .collection("friends")
                                .doc(results)
                                .update({"tracking": value});
                          });
                        });
                  });
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add_alt),
        onPressed: () {
          // ADD FRIENDS BOX
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: const Text('Add Friend'),
                      content: TextField(
                        controller: emailController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            labelText: 'Enter a Username'),
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
                                    .where("username",
                                        isEqualTo: emailController.text)
                                    .get()
                                    .then((querySnapshot) {
                                  friendUID = querySnapshot.docs[0].id;
                                });
                              }
                              _friendDoesNotExist =
                                  friendUID == 'null' || friendUID == '';
                              // Friend exists so now we add em
                              if (!_friendDoesNotExist) {
                                var firebaseUser =
                                    FirebaseAuth.instance.currentUser;
                                if (firebaseUser != null) {
                                  await FirebaseFirestore.instance
                                      .collection('userEmails')
                                      .doc(firebaseUser.uid)
                                      .get()
                                      .then((res) {
                                    username = res['username'].toString();
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('userEmails')
                                      .doc(friendUID)
                                      .collection("requests")
                                      .doc(firebaseUser.uid)
                                      .set({
                                    // Appending to field array
                                    "username": username,
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
}
