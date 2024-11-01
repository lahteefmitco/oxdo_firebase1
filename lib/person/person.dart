import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? id;
  final String name;
  final int age;

  Person({this.id, required this.name, required this.age});


  /// From firestore, It is used to convert map to class
  factory Person.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Person(id: snapshot.id,name:data?["name"], age: data?["age"]);
  }

  Map<String, dynamic> toFirestore() {
    return {"name": name, "age": age};
  }

  @override
  String toString() {
    return "id: $id, name: $name,  age: $age";
  }
}
