import 'package:chatapp_firebase/widgets/button.dart';
import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final controller;

  //save method
  VoidCallback onSaved;

  //cancel method
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.controller,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      content: SizedBox(
        height: 120,
        child: Column(
          children: [
            //get user Input
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Add a new task",
              ),
            ),


            //buttons -> save & cancel
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //save button
                MyButton(onPressed: onSaved, text: "Save"),

                const SizedBox(
                  width: 10,
                ),

                //cancel button
                MyButton(onPressed: onCancel, text: "Cancel"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
