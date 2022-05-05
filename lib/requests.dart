import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// FRIENDS REQUESTS CLASS
class FriendsRequests extends StatefulWidget {
  const FriendsRequests({Key? key}) : super(key: key);
  @override
  State<FriendsRequests> createState() => _FriendsRequestsState();
}

class _FriendsRequestsState extends State<FriendsRequests> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  late var requestDocs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Friend Requests'),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('userEmails')
                .doc(_uid)
                .collection('requests')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                requestDocs = snapshot.data?.docs;
                return ListView.separated(
                    itemCount: requestDocs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          requestDocs[index]['username'],
                          style: const TextStyle(fontSize: 18),
                        ),
                        trailing: Wrap(
                          children: [
                            // REJECT REQUEST
                            IconButton(
                              icon: const Icon(
                                Icons.indeterminate_check_box,
                                size: 30,
                              ),
                              onPressed: (() async {
                                await FirebaseFirestore.instance.runTransaction(
                                    (Transaction myTransaction) async {
                                  myTransaction
                                      .delete(requestDocs[index].reference);
                                });
                              }),
                            ),
                            // ACCEPT REQUEST
                            IconButton(
                              icon: const Icon(Icons.add_box,
                                  size: 30, color: Colors.green),
                              color: Colors.green,
                              onPressed: () async {
                                var firebaseUser =
                                    FirebaseAuth.instance.currentUser;
                                // Getting current user's username
                                String username = '';
                                await FirebaseFirestore.instance
                                    .collection('userEmails')
                                    .doc(firebaseUser?.uid)
                                    .get()
                                    .then((querySnapshot) {
                                  username = querySnapshot['username'];
                                });
                                // Getting the friend's uid
                                String friendUID = '';
                                await FirebaseFirestore.instance
                                    .collection('userEmails')
                                    .where('username',
                                        isEqualTo: requestDocs[index]
                                            ['username'])
                                    .get()
                                    .then((querySnapshot) {
                                  friendUID = querySnapshot.docs[0].id;
                                });
                                if (firebaseUser != null) {
                                  FirebaseFirestore.instance
                                      .collection('userEmails')
                                      .doc(firebaseUser.uid)
                                      .collection('requests')
                                      .where('username',
                                          isEqualTo: requestDocs[index]
                                              ['username'])
                                      .get()
                                      .then((res) {
                                    final results = res.docs[0].id;
                                    // Adding friend to the user's list
                                    FirebaseFirestore.instance
                                        .collection('userEmails')
                                        .doc(firebaseUser.uid)
                                        .collection('friends')
                                        .doc(results)
                                        .set({
                                      'username': requestDocs[index]
                                          ['username'],
                                      'tracking': false,
                                      'uid': friendUID
                                    });
                                    // Adding this user to the friend's list
                                    FirebaseFirestore.instance
                                        .collection('userEmails')
                                        .doc(results)
                                        .collection('friends')
                                        .doc(firebaseUser.uid)
                                        .set({
                                      'username': username,
                                      'tracking': false,
                                      'uid': firebaseUser.uid,
                                    });
                                  });
                                }
                                await FirebaseFirestore.instance.runTransaction(
                                    (Transaction myTransaction) async {
                                  myTransaction
                                      .delete(requestDocs[index].reference);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    });
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text('Nothing to show here!')],
              );
            }));
  }
}
