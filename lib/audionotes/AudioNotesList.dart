import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";

import 'AudioNotesModel.dart' show AudioNote, AudioNotesModel, audioNotesModel;

/// The AudioNotes List sub-screen.
class AudioNotesList extends StatelessWidget {
  Widget build(BuildContext inContext) {
    print("-- AudioNotesList.build()");
    return ScopedModel<AudioNotesModel>(
        model: audioNotesModel,
        child: ScopedModelDescendant<AudioNotesModel>(
            builder: (BuildContext inContext, Widget inChild, AudioNotesModel inModel) {
          return Scaffold(
            // Add AudioNote.
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white), onPressed: () async {}),
            body: ListView.builder(
                itemCount: audioNotesModel.entityList.length,
                itemBuilder: (BuildContext inBuildContext, int inIndex) {
                  AudioNote note = audioNotesModel.entityList[inIndex];
                  // Determine note background color, default is white
                  Color color = Colors.white;
                  switch (note.color) {
                    case "red":
                      color = Colors.red;
                      break;
                    case "green":
                      color = Colors.green;
                      break;
                    case "blue":
                      color = Colors.blue;
                      break;
                    case "yellow":
                      color = Colors.yellow;
                      break;
                    case "grey":
                      color = Colors.grey;
                      break;
                    case "purple":
                      color = Colors.purple;
                      break;
                  }
                  return Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Slidable(
                          delegate: SlidableDrawerDelegate(),
                          actionExtentRatio: .25,
                          secondaryActions: [
                            IconSlideAction(
                                caption: "Delete",
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {})
                          ],
                          child: Card(
                              elevation: 8,
                              color: color,
                              child: ListTile(
                                  title: Text("${note.title}"),
                                  subtitle: Text("${note.content}"),
                                  // Edit existing note.
                                  onTap: () async {}))));
                }),
          );
        }));
  }
}
