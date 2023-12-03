import 'package:hive/hive.dart';

class ToDoDatabase{

  List toDoList = [];

  //references our box
  final _myBox = Hive.box('myBox');

  //run this method if thius is 1st time opening
  void createInitialData(){
    toDoList = [
      ["First task",false],
      ["Second task", false],
    ];
  } 

  //load the data from database
  void loadData(){
    toDoList = _myBox.get("TODOLIST");
  }

  //update the database
  void updateDatabase(){
    _myBox.put("TODOLIST", toDoList);
  }
}