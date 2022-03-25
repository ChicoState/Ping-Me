import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FRIENDS PAGE CLASS
class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
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
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            // DUMMY ENTRIES
            friendEntry('friend1'),
            friendEntry('friend2'),
            friendEntry('friend3'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
