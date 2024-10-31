class Person {
  String? id;
  final String name;
  final int age;

  Person({this.id,required this.name, required this.age});

  factory Person.fromJson(Map<String, dynamic> json,String id) {
    return Person(id: id,name: json["name"] as String, age: json["age"] as int);
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "age": age};
  }

  @override
  String toString() {
    return "id: $id, name: $name,  age: $age";
  }
}
