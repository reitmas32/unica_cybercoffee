class Computer {
  Computer({
    this.id = -1,
    required this.name,
    required this.idRoom,
    required this.type,
    this.x = 0.0,
    this.y = 0.0,
    this.state = '',
    this.message = '',
  });

  int id;
  int idRoom;
  double x;
  double y;
  String name;
  String state;
  String type;
  String message;

  static Computer fromJson(Map<dynamic, dynamic> data) {
    return Computer(
      id: data['ID'],
      idRoom: data['IdRoom'],
      x: data['Pos_x'].toDouble(),
      y: data['Pos_y'].toDouble(),
      name: data['Name'],
      state: data['State'],
      type: data['Type'],
      message: data['Message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "id_room": idRoom,
      "name": name,
      "state": state,
      "x": x,
      "y": y,
      "type": type,
      "message": message,
    };
  }

  @override
  String toString() =>
      'Computer{name: $name, state: $state, idRoom: $idRoom, id: $id}';
}