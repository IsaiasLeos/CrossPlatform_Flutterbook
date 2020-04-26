import "dart:io";

import "package:flutter/material.dart";
import 'package:inclasswork/audionotes/Documents.dart';
import "package:path_provider/path_provider.dart";

import 'appointments/Appointments.dart';
import "contacts/Contacts.dart";
import "notes/Notes.dart";
import "tasks/Tasks.dart";
import "utils.dart" as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print("-- main(): FlutterBook Starting");
  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  Widget build(BuildContext inContext) {
    print("-- FlutterBook.build()");

    return MaterialApp(
        home: DefaultTabController(
            length: 5,
            child: Scaffold(
                appBar: AppBar(
                    title: Text("Isaias Leos"),
                    bottom: TabBar(tabs: [
                      Tab(icon: Icon(Icons.date_range), text: "Appointments"),
                      Tab(icon: Icon(Icons.contacts), text: "Contacts"),
                      Tab(icon: Icon(Icons.note), text: "Notes"),
                      Tab(icon: Icon(Icons.assignment_turned_in), text: "Tasks"),
                      Tab(icon: Icon(Icons.attach_file), text: "Documents")
                    ])),
                body: TabBarView(
                    children: [Appointments(), Contacts(), Notes(), Tasks(), Documents()]))));
  }
}
