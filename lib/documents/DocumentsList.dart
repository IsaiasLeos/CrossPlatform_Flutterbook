import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_file/open_file.dart';
import 'package:scoped_model/scoped_model.dart';

import 'DocumentsDBWorker.dart';
import 'DocumentsModel.dart';

/// The Document List sub-screen.
class DocumentsList extends StatefulWidget {
  _DocumentsListState createState() => new _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  String _path;
  String _extension;
  FileType _pickingType;

  void _openFileExplorer(BuildContext inContext, bool save) async {
    try {
      _path = await FilePicker.getFilePath(
          type: _pickingType,
          allowedExtensions: (_extension?.isNotEmpty ?? false)
              ? _extension?.replaceAll(' ', '')?.split(',')
              : null);
    } on Exception catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    documentsModel.entityBeingEdited = Document();
    documentsModel.setStackIndex(0);
    documentsModel.entityBeingEdited.path = _path;
    if (save) {
      _save(inContext, documentsModel);
    } else {
      _edit(inContext, documentsModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set value of controllers

    return ScopedModel<DocumentsModel>(
        model: documentsModel,
        child: ScopedModelDescendant<DocumentsModel>(
            builder: (BuildContext inContext, Widget inChild, DocumentsModel inModel) {
          return new Scaffold(
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  _openFileExplorer(inContext, true);
                }),
            body: ListView.builder(
              itemCount: documentsModel.entityList.length,
              itemBuilder: (BuildContext context, int inIndex) {
                Document document = documentsModel.entityList[inIndex];
                var offset = inIndex + 1;
                final String name = 'File $offset: ${document.path.split('/').last}';
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actionExtentRatio: .25,
                  secondaryActions: [
                    IconSlideAction(
                        caption: "Delete",
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          _deleteNote(inContext, document);
                        }),
                    IconSlideAction(
                        caption: "Edit",
                        color: Colors.green,
                        icon: Icons.edit,
                        onTap: () {
                          _openFileExplorer(inContext, false);
                        })
                  ],
                  child: new ListTile(
                    onTap: () {
                      Future<void> openFile() async {
                        var currentPath = document.path;
                        print("-- Path: $currentPath");
                        await OpenFile.open(currentPath);
                      }

                      openFile();
                    },
                    title: new Text(
                      name,
                    ),
                    subtitle: new Text(document.path),
                  ),
                );
              },
            ),
          );
        }));
  }

  /// Save to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _edit(BuildContext inContext, DocumentsModel inDocumentModel) async {
    print("-- DocumentList._save()");
    print("-- DocumentList._save() - ${documentsModel.path}");
    // Creating a new note.
    if (inDocumentModel.entityBeingEdited.id == null) {
      print("-- DocumentsList._save(): Creating: ${inDocumentModel.entityBeingEdited}");
      await DocumentsDBWorker.db.create(documentsModel.entityBeingEdited);
      // Updating an existing note.
    }

    // Reload data from database to update list.
    documentsModel.loadData("documents", DocumentsDBWorker.db);

    // Go back to the list view.
    inDocumentModel.setStackIndex(0);

    // Show SnackBar.
    Scaffold.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Document Saved")));
  }

  /// Save to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _save(BuildContext inContext, DocumentsModel inDocumentModel) async {
    print("-- DocumentList._save()");
    print("-- DocumentList._save() - ${documentsModel.path}");
    // Creating a new note.
    if (inDocumentModel.entityBeingEdited.id == null) {
      print("-- DocumentsList._save(): Creating: ${inDocumentModel.entityBeingEdited}");
      await DocumentsDBWorker.db.create(documentsModel.entityBeingEdited);
      // Updating an existing note.
    }

    // Reload data from database to update list.
    documentsModel.loadData("documents", DocumentsDBWorker.db);

    // Go back to the list view.
    inDocumentModel.setStackIndex(0);

    // Show SnackBar.
    Scaffold.of(inContext).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Document Saved")));
  }

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @param  inNote    The note (potentially) being deleted.
  /// @return           Future.
  Future _deleteNote(BuildContext inContext, Document inDocument) async {
    print("-- DocumentsList._deleteNote(): inDocument = $inDocument");

    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
              title: Text("Delete Document"),
              content: Text("Are you sure you want to delete ${inDocument.path.split('/').last}?"),
              actions: [
                FlatButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      // Just hide dialog.
                      Navigator.of(inAlertContext).pop();
                    }),
                FlatButton(
                    child: Text("Delete"),
                    onPressed: () async {
                      // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                      await DocumentsDBWorker.db.delete(inDocument.id);
                      Navigator.of(inAlertContext).pop();
                      Scaffold.of(inContext).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Document Deleted")));
                      // Reload data from database to update list.
                      documentsModel.loadData("documents", DocumentsDBWorker.db);
                    })
              ]);
        });
  }
}
