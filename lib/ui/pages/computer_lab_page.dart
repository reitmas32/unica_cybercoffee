import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unica_cybercoffee/domain/models/computer_ui.dart';
import 'package:unica_cybercoffee/domain/models/computer_room.dart';
import 'package:unica_cybercoffee/services/DB/database_ui_static.dart';
import 'package:unica_cybercoffee/services/DB/idatabase_ui.dart';
import 'package:unica_cybercoffee/ui/providers/editable_ui_provider.dart';
import 'package:unica_cybercoffee/ui/widgets/dialogs/add_computer_dialog.dart';
import 'package:unica_cybercoffee/ui/widgets/appbar/unicaAppBar.dart';
import 'package:unica_cybercoffee/ui/widgets/custom_tab_view.dart';
import 'package:unica_cybercoffee/ui/widgets/table_computers.dart';

class ComputersPage extends StatefulWidget {
  const ComputersPage({super.key});

  @override
  ComputersPageState createState() => ComputersPageState();
}

class ComputersPageState extends State<ComputersPage> {
  int initPosition = 0;
  int lastPos = 0;
  //List<List<Position>> unica = [[], [], []];
  List<ComputerRoomUI> computerRooms = [];
  List<ComputerUI> computers = [];
  DataBaseStaticUI databaseUI = databaseUIStatic;

  _loadComputerRooms(IDataBaseUI database) async {
    List<ComputerRoomUI> computerRoomsTmp = await database.getComputerRooms();
    setState(() {
      computerRooms = computerRoomsTmp;
    });
  }

  _createComputerRooms(DataBaseStaticUI database) async {
    await database.loadData();
    List<ComputerUI> computerTmp = await database.getComputers();
    setState(() {
      computers = computerTmp;
    });
  }

  _addNewComputerRoom(IDataBaseUI database, String nameNewAula) async {
    setState(
      () {
        database.deleteComputerRooms('Nueva Aula');
        database.createComputerRooms(nameNewAula);
        database.createComputerRooms('Nueva Aula');
      },
    );
  }

  _addNewComputer(IDataBaseUI database, String nameComputerRoom,
      String nameComputer) async {
    await database.createComputer(nameComputerRoom, nameComputer);
    // ignore: no_leading_underscores_for_local_identifiers
    List<ComputerUI> _computers = await database.getComputers();
    setState(() {
      computers = _computers;
    });
  }

  @override
  void deactivate() async {
    await databaseUI.saveData();
    super.deactivate();
  }

  @override
  void initState() {
    _createComputerRooms(databaseUI);

    _loadComputerRooms(databaseUI);

    super.initState();
  }

  TextEditingController nameNewComputer = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final editableUIProvider = Provider.of<EditableUIProvider>(context);
    return Scaffold(
      appBar: const UnicaAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: CustomTabView(
          initPosition: initPosition,
          itemCount: computerRooms.length,
          tabBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              computerRooms[index].name,
              style: const TextStyle(fontSize: 20.0),
            ),
          ),
          pageBuilder: (context, index) {
            if (index == computerRooms.length - 1) {
              return const Center(
                child: Text(
                  'Activa la edicion de la UI para crear una nueva Aula',
                  style: TextStyle(fontSize: 30.0),
                ),
              );
            }
            return TableComputers(
              computers: computers
                  .where((element) =>
                      element.idComputerRoom == computerRooms[index].id)
                  .toList(),
            );
          },
          onPositionChange: (index) {
            if (index == computerRooms.length - 1) {
              if (computerRooms.length == 1) {
                _addNewComputerRoom(databaseUI, 'Aula ${index + 1}');
                _loadComputerRooms(databaseUI);
                initPosition = computerRooms.length - 2;
              } else if (editableUIProvider.editable) {
                _addNewComputerRoom(databaseUI, 'Aula ${index + 1}');
                _loadComputerRooms(databaseUI);
                initPosition = computerRooms.length - 2;
              } else {
                initPosition = lastPos;
                return;
              }
            } else {
              initPosition = index;
            }
            lastPos = index;
          },
          onScroll: (position) {},
        ),
      ),
      floatingActionButton: Material(
        borderRadius: BorderRadius.circular(35.0),
        elevation: editableUIProvider.editable ? 15.0 : 1.0,
        shadowColor:
            editableUIProvider.editable ? Colors.blue : Colors.transparent,
        child: FloatingActionButton(
          backgroundColor:
              editableUIProvider.editable ? Colors.blue : Colors.blueGrey,
          onPressed: editableUIProvider.editable
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => AddComputerDialog(
                      nameNewComputer: nameNewComputer,
                      onTap: () {
                        _addNewComputer(databaseUI, computerRooms[lastPos].name,
                            nameNewComputer.text);
                        setState(() {
                          nameNewComputer.text = '';
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                }
              : null,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}