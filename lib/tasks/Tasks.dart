import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";

import 'TasksDBWorker.dart';
import 'TasksEntry.dart';
import 'TasksList.dart';
import 'TasksModel.dart';

/// The Tasks screen
class Tasks extends StatelessWidget {
  Tasks() {
    print("-- Tasks.constructor");

    // Initial load
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  Widget build(BuildContext inContext) {
    print("-- Tasks.build()");

    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext inContext, Widget inChild, TasksModel inModel) {
          return IndexedStack(index: inModel.stackIndex, children: [TasksList(), TasksEntry()]);
        }));
  }
}
