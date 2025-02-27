import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oxdo_firebase1/main.dart';
import 'package:oxdo_firebase1/person/person.dart';
import 'package:oxdo_firebase1/save_button_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

 
  // Firestore collection name
  final String collectionName = "PersonData";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _ageFocus = FocusNode();

  // Initialize person list
  final List<Person> _personList = [];

  SaveButtonMode _saveButtonMode = SaveButtonMode.save;

  // Only for updating
  Person? _personToUpdate;

  bool _showProgressBar = false;

  void _addPersonDataTofirebase(Person person) async {
    _showProgressBar = true;
    setState(() {});
    await fdb
        .collection(collectionName)
        .add(person.toJson())
        .then((DocumentReference<Map<String, dynamic>> docRef) {
      final String id = docRef.id;
      log("Insert Data with $id", name: "oxdo");
    }).onError((e, stack) {
      log("Error on inserting $e", name: "oxdo");
    });
    _nameController.clear();
    _ageController.clear();

    _unFocusAllFocusNode();

    _getAllPersonListFromFirestore();
  }

  void _getAllPersonListFromFirestore() async {
    _personList.clear();
    final QuerySnapshot<Map<String, dynamic>> querySnapShot =
        await fdb.collection(collectionName).get();
    for (var element in querySnapShot.docs) { 
      final String id = element.id;
      final Map<String, dynamic> data = element.data();
      _personList.add(Person.fromJson(data, id));
    }
    _showProgressBar = false;
    setState(() {});
  }

  void _bringPersonToUpdate(Person person) {
    _nameController.text = person.name;
    _ageController.text = person.age.toString();
    _saveButtonMode = SaveButtonMode.edit;
    _personToUpdate = person;
    setState(() {});
  }

  void _updatePersonInFireStore(Person personToUpdate) async {
    _showProgressBar = true;
    setState(() {});
    final DocumentReference<Map<String, dynamic>> documentRef =
        fdb.collection(collectionName).doc(personToUpdate.id);
    await documentRef.update(personToUpdate.toJson()).then((value) {
      log("Updated successfully", name: "oxdo");
    }).onError((e, stack) {
      log("Error is $e", name: "oxdo");
    });

    
    _nameController.clear();
    _ageController.clear();
    _saveButtonMode = SaveButtonMode.save;

    _unFocusAllFocusNode();

    _getAllPersonListFromFirestore();
  }

  void _deleteAPersonInFireStore(String id) async {
    _showProgressBar = true;
    setState(() {
      
    });
    await fdb.collection(collectionName).doc(id).delete();
    _getAllPersonListFromFirestore();
  }

  @override
  void initState() {
    _showProgressBar = true;
    setState(() {});

    // initial loading of all data from firestore
    _getAllPersonListFromFirestore();
    super.initState();
  }

  // un focus text fields,  hide keyboard
  void _unFocusAllFocusNode() {
    _nameFocusNode.unfocus();
    _ageFocus.unfocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();

    _nameFocusNode.dispose();
    _ageFocus.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Firestore"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),

        // Stack to display list and progressbar
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // name field
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Name"),
                      hintText: "Enter name",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // age field
                  TextField(
                    controller: _ageController,
                    focusNode: _ageFocus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Age"),
                      hintText: "Enter age",
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  // save or edit buttton
                  ElevatedButton(
                    onPressed: () {
                      if (_saveButtonMode == SaveButtonMode.save) {
                        // To save
                        final personToSave = Person(
                          name: _nameController.text.trim(),
                          age: int.tryParse(_ageController.text.trim()) ?? 0,
                        );
                        _addPersonDataTofirebase(personToSave);
                      } else {
                        // To update
                        final personToUpdate = Person(
                          id: _personToUpdate?.id,
                          name: _nameController.text.trim(),
                          age: int.tryParse(_ageController.text.trim()) ?? 0,
                        );

                        _updatePersonInFireStore(personToUpdate);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _saveButtonMode == SaveButtonMode.save
                          ? Colors.green
                          : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_saveButtonMode == SaveButtonMode.save
                        ? "Save"
                        : "Update"),
                  ),
                  const SizedBox(
                    height: 8,
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final person = _personList[index];

                        return Card(
                          child: ListTile(
                            title: Text("Name:- ${person.name}"),
                            subtitle: Text("Age:- ${person.age}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // take data to update
                                    _bringPersonToUpdate(person);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (person.id != null) {
                                      _deleteAPersonInFireStore(person.id!);
                                    }
                                  },
                                  color: Colors.red,
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: _personList.length,
                    ),
                  )
                ],
              ),
              // This trailing comma makes auto-formatting nicer for build methods.
            ),
            if (_showProgressBar)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
      ),
    );
  
  }
}
