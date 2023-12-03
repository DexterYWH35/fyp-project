import 'package:chatapp_firebase/data/database.dart';
import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/auth/login_page.dart';
import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/pages/profile_page.dart';
import 'package:chatapp_firebase/widgets/dialog_box.dart';
import 'package:chatapp_firebase/widgets/todo_tile.dart';
import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TaskCreation extends StatefulWidget {
  const TaskCreation({super.key});

  @override
  State<TaskCreation> createState() => _TaskCreationState();
}

class _TaskCreationState extends State<TaskCreation> {
  // reference for the hive box
  final _myBox = Hive.box("myBox");
  ToDoDatabase db = ToDoDatabase();

  //initialized purpose to display users detais
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  String groupName = "";

  //task creation controller
  final _controller = TextEditingController();


  //check box was tapped
  void checkBoxChanged(bool? value, int index){
    setState((){
          db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  //create new tasks method
  void createNewTask(){
    showDialog(context: context, builder: (context){
      return DialogBox(
        controller: _controller,
        onSaved: saveNewTask,
        onCancel: () => Navigator.of(context).pop(),
      );
    },
    );
  }

  //delete tasks
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  // save new tasks
  void saveNewTask(){
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  //get data user
  @override
  void initState() {
  //if this is 1st time opening app it create default data
  if(_myBox.get("TODOLIST") == null){
    db.createInitialData();

    super.initState();
    gettingUserData();
  }else{
    db.loadData();

    super.initState();
    gettingUserData();
  }
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    // getting the list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Task Lists',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 27,
          ),
        ),
      ),
      //SIDE bar
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        //Returning List of item (Groups, Profile, Logout and Task Creation)
        children: <Widget>[
          Icon(
            Icons.person,
            size: 150,
            color: Colors.grey[700],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          //Groups
          ListTile(
            onTap: () {
              nextScreen(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.groups),
            title: const Text(
              "Groups",
              style: TextStyle(color: Colors.black),
            ),
          ),
          //Profile
          ListTile(
            onTap: () {
              nextScreenReplace(
                  context,
                  ProfilePage(
                    userName: userName,
                    email: email,
                  ));
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.person_pin_outlined),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
          //Task Creation
          ListTile(
            selected: true,
            onTap: () {
              nextScreen(
                  context,
                  const TaskCreation(
                      // userName: userName,
                      // email: email,
                      ));
            },
            selectedColor: Theme.of(context).primaryColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.note_add_outlined),
            title: const Text(
              "Task",
              style: TextStyle(color: Colors.black),
            ),
          ),
          //Logout
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      //END OF SIDE BAR//

      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),

      //BODY
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0],
            taskCompleted: db.toDoList[index][1],
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
