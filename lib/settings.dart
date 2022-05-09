import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// firestore class
// class FireStoreDataBase {
//   List friendList = [];
//   final CollectionReference collectionRef =
//       FirebaseFirestore.instance.collection("userEmails");

//   Future getData() async {
//     try {
//       var firebaseUser = FirebaseAuth.instance.currentUser;
//       if (firebaseUser != null) {
//         await collectionRef
//             .doc(firebaseUser.uid)
//             .collection("friends")
//             .get()
//             .then((querySnapshot) {
//           for (var result in querySnapshot.docs) {
//             friendList.add(result.data());
//           }
//         });
//       }
//       return friendList;
//     } catch (e) {
//       debugPrint("Error - $e");
//       return null;
//     }
//   }
// }

// SETTINGS CLASS

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // structure of the view page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.4)),
                margin: const EdgeInsets.all(32.0),
                color: Colors.yellow,
                child: const ListTile(
                  title: Text('John Doe'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                "My Account",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(children: <Widget>[
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: Colors.blueAccent,
                    ),
                    title: const Text("Change Account Details"),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(
                      Icons.password_outlined,
                      color: Colors.blueAccent,
                    ),
                    title: const Text("Change Password"),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_outlined,
                      color: Colors.blueAccent,
                    ),
                    title: const Text("Log-out"),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.blueAccent,
                    ),
                    title: const Text("Delete Account"),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {},
                  ),
                ]),
              ),
            ],
          )),
    );
  }
}

Container _buildDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8.0),
    width: double.infinity,
    height: 1.0,
    color: Colors.grey.shade400,
  );
}

/**
 * A container is a widget that takes a width, heigh, and child property
 * the only property needed is a child
 * A container is a widget that takes another widget as a child
 * * text view, list view
 * Container will be decalred within the container
 */