import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:unica_cybercoffee/domain/models/computerUI.dart';
import 'package:unica_cybercoffee/domain/models/computer_room.dart';
import 'package:unica_cybercoffee/services/DB/idatabase_UI.dart';
import 'package:unica_cybercoffee/tools/randomID.dart';

class DataBaseStaticUI extends IDataBaseUI {
  List<ComputerUI> computers = [];
  List<ComputerRoomUI> computerRooms = [];

  Future<bool> loadData() async {
    final directory = await getApplicationSupportDirectory();
    final collectionComputersFile =
        File('${directory.path}/collection_computers.json');
    if (!await collectionComputersFile.exists()) {
      await collectionComputersFile.create();
    } else {
      final collectionComputersJson =
          collectionComputersFile.readAsStringSync();
      if (!collectionComputersJson.isEmpty) {
        final List<dynamic> collectionComputersList =
            jsonDecode(collectionComputersJson);
        computers = collectionComputersList
            .map((json) => ComputerUI.fromMap(json))
            .toList();
      }
    }

    final collectionComputerRoomsFile =
        File('${directory.path}/collection_computer_rooms.json');
    if (!await collectionComputerRoomsFile.exists()) {
      await collectionComputerRoomsFile.create();
    } else {
      final collectionComputerRoomsJson =
          collectionComputerRoomsFile.readAsStringSync();
      if (!collectionComputerRoomsJson.isEmpty) {
        final List<dynamic> collectionComputerRoomsList =
            jsonDecode(collectionComputerRoomsJson);
        computerRooms = collectionComputerRoomsList
            .map((json) => ComputerRoomUI.fromMap(json))
            .toList();
      }else{
        await createComputerRooms('Nueva Aula');
      }
    }

    return Future(() => true);
  }

  Future<bool> saveData() async {
    final directory = await getApplicationSupportDirectory();
    final collectionComputers =
        File('${directory.path}/collection_computers.json');
    final sinkCollectionComputers = collectionComputers.openWrite();

    final collectionComputerRooms =
        File('${directory.path}/collection_computer_rooms.json');
    final sinkCollectionComputerRooms = collectionComputerRooms.openWrite();

    sinkCollectionComputers.write(
        jsonEncode(computers.map((computer) => computer.toJson()).toList()));
    sinkCollectionComputerRooms.write(jsonEncode(
        computerRooms.map((computer) => computer.toJson()).toList()));

    await sinkCollectionComputers.flush();
    await sinkCollectionComputers.close();
    return Future(() => true);
  }

  @override
  Future<ComputerUI> createComputer(
      String nameRoom, String nameComputer) async {
    final randomID = randomString();
    var computerRoom = await findComputerRooms(nameRoom);
    var computer = ComputerUI(
      name: nameComputer,
      imageUrl: 'imageUrl',
      state: 'state',
      id: randomID,
      x: 0,
      y: 0,
      idComputerRoom: computerRoom.id,
    );
    computers.add(
      computer,
    );

    return Future(() => computer);
  }

  @override
  Future<bool> deleteComputer(String nameComputer) async {
    return Future(() => false);
  }

  @override
  Future<List<ComputerUI>> getComputers() async {
    // TODO: implement getComputers
    return computers;
  }

  @override
  Future<String> createComputerRooms(String nameRoom) async {
    final randomID = randomString();
    computerRooms.add(
      ComputerRoomUI(id: randomID, name: nameRoom),
    );
    return Future(() => randomID);
  }

  @override
  Future<ComputerRoomUI> findComputerRooms(String nameRoom) async {
    ComputerRoomUI result = computerRooms.firstWhere(
        (computerRoom) => computerRoom.name == nameRoom,
        orElse: () => ComputerRoomUI(name: 'None'));

    return result;
  }

  @override
  Future<List<ComputerRoomUI>> getComputerRooms() async {
    return Future(() => computerRooms);
  }

  @override
  Future<bool> deleteComputerRooms(String nameRoom) async {
    computerRooms.removeLast();
    return Future(() => true);
  }
}

DataBaseStaticUI databaseUI_Static = DataBaseStaticUI();
