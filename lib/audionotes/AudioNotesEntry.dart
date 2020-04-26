import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";

import 'AudioNotesDBWorker.dart';
import 'AudioNotesModel.dart' show AudioNotesModel, audioNotesModel;

/// The Notes Entry sub-screen.
class AudioNotesEntry extends StatelessWidget {
  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();

  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Constructor.
  AudioNotesEntry() {
    print("-- NotesEntry.constructor");

    // Attach event listeners to controllers to capture entries
    _titleEditingController.addListener(() {
      audioNotesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      audioNotesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  Widget build(BuildContext inContext) {
    print("-- NotesEntry.build()");

    // Set value of controllers.
    if (audioNotesModel.entityBeingEdited != null) {
      _titleEditingController.text = audioNotesModel.entityBeingEdited.title;
      _contentEditingController.text = audioNotesModel.entityBeingEdited.content;
    }
    return ScopedModel(
        model: audioNotesModel,
        child: ScopedModelDescendant<AudioNotesModel>(
            builder: (BuildContext inContext, Widget inChild, AudioNotesModel inModel) {
          return Scaffold(
              bottomNavigationBar: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  child: Row(children: [
                    FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          // Hide soft keyboard.
                          FocusScope.of(inContext).requestFocus(FocusNode());
                          // Go back to the list view.
                          inModel.setStackIndex(0);
                        }),
                    Spacer(),
                    FlatButton(
                        child: Text("Save"),
                        onPressed: () {
                          _save(inContext, audioNotesModel);
                        })
                  ])),
              body: Form(
                  key: _formKey,
                  child: ListView(children: [
                    // Title.
                    ListTile(
                        leading: Icon(Icons.title),
                        title: TextFormField(
                            decoration: InputDecoration(hintText: "Title"),
                            controller: _titleEditingController,
                            validator: (String inValue) {
                              if (inValue.length == 0) {
                                return "Please enter a title";
                              }
                              return null;
                            })),
                    // Content.
                    ListTile(
                        leading: Icon(Icons.content_paste),
                        title: TextFormField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 8,
                            decoration: InputDecoration(hintText: "Content"),
                            controller: _contentEditingController,
                            validator: (String inValue) {
                              if (inValue.length == 0) {
                                return "Please enter content";
                              }
                              return null;
                            })),
                    // Note color.
                    ListTile(
                        leading: Icon(Icons.color_lens),
                        title: Row(children: [
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(color: Colors.red, width: 18) +
                                          Border.all(
                                              width: 6,
                                              color: audioNotesModel.color == "red"
                                                  ? Colors.red
                                                  : Theme.of(inContext).canvasColor))),
                              onTap: () {
                                audioNotesModel.entityBeingEdited.color = "red";
                                audioNotesModel.setColor("red");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(color: Colors.green, width: 18) +
                                          Border.all(
                                              width: 6,
                                              color: audioNotesModel.color == "green"
                                                  ? Colors.green
                                                  : Theme.of(inContext).canvasColor))),
                              onTap: () {
                                audioNotesModel.entityBeingEdited.color = "green";
                                audioNotesModel.setColor("green");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(color: Colors.blue, width: 18) +
                                          Border.all(
                                              width: 6,
                                              color: audioNotesModel.color == "blue"
                                                  ? Colors.blue
                                                  : Theme.of(inContext).canvasColor))),
                              onTap: () {
                                audioNotesModel.entityBeingEdited.color = "blue";
                                audioNotesModel.setColor("blue");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(color: Colors.yellow, width: 18) +
                                          Border.all(
                                              width: 6,
                                              color: audioNotesModel.color == "yellow"
                                                  ? Colors.yellow
                                                  : Theme.of(inContext).canvasColor))),
                              onTap: () {
                                audioNotesModel.entityBeingEdited.color = "yellow";
                                audioNotesModel.setColor("yellow");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(color: Colors.grey, width: 18) +
                                          Border.all(
                                              width: 6,
                                              color: audioNotesModel.color == "grey"
                                                  ? Colors.grey
                                                  : Theme.of(inContext).canvasColor))),
                              onTap: () {
                                audioNotesModel.entityBeingEdited.color = "grey";
                                audioNotesModel.setColor("grey");
                              }),
                          Spacer(),
                          GestureDetector(
                              child: Container(
                                  decoration: ShapeDecoration(
                                      shape: Border.all(color: Colors.purple, width: 18) +
                                          Border.all(
                                              width: 6,
                                              color: audioNotesModel.color == "purple"
                                                  ? Colors.purple
                                                  : Theme.of(inContext).canvasColor))),
                              onTap: () {
                                audioNotesModel.entityBeingEdited.color = "purple";
                                audioNotesModel.setColor("purple");
                              })
                        ]))
                  ])));
        }));
  }

  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _save(BuildContext inContext, AudioNotesModel inModel) async {
    print("-- NotesEntry._save()");

    // Abort if form isn't valid.
    if (!_formKey.currentState.validate()) {
      return;
    }

    // Creating a new note.
    if (inModel.entityBeingEdited.id == null) {
      print("-- NotesEntry._save(): Creating: ${inModel.entityBeingEdited}");
      await AudioNotesDBWorker.db.create(audioNotesModel.entityBeingEdited);

      // Updating an existing note.
    } else {
      print("-- NotesEntry._save(): Updating: ${inModel.entityBeingEdited}");
      await AudioNotesDBWorker.db.update(audioNotesModel.entityBeingEdited);
    }

    // Reload data from database to update list.
    audioNotesModel.loadData("notes", AudioNotesDBWorker.db);

    // Go back to the list view.
    inModel.setStackIndex(0);

    // Show SnackBar.
    Scaffold.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Note saved")));
  }
}
