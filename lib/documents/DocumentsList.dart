import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
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

  void _openFileExplorer(BuildContext inContext, bool save, int index) async {
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
    print(_path);
    if (save) {
      _save(inContext, documentsModel);
    } else {
      _edit(inContext, documentsModel, index);
    }
  }

  void imageSelectorCamera(BuildContext context) async {
    var imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    var filepath = imageFile.toString().split(": '")[1];
    documentsModel.entityBeingEdited = Document();
    documentsModel.setStackIndex(0);
    documentsModel.entityBeingEdited.path = filepath.substring(0, filepath.length - 1);
    print(imageFile);
    _save(context, documentsModel);
  }

  void imageSelectorGallery(BuildContext context) async {
    var imageFile1 = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    var filepath = imageFile1.toString().split(": '")[1];
    documentsModel.entityBeingEdited = Document();
    documentsModel.setStackIndex(0);
    documentsModel.entityBeingEdited.path = filepath.substring(0, filepath.length - 1);
    print(_path);
    _save(context, documentsModel);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<DocumentsModel>(
        model: documentsModel,
        child: ScopedModelDescendant<DocumentsModel>(
            builder: (BuildContext inContext, Widget inChild, DocumentsModel inModel) {
          return new Scaffold(
            floatingActionButton: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              children: [
                SpeedDialChild(
                  child: Icon(Icons.add),
                  label: "File Explorer",
                  onTap: () {
                    _openFileExplorer(inContext, true, 0);
                  },
                ),
                SpeedDialChild(
                    child: Icon(Icons.camera),
                    label: "Camera",
                    onTap: () {
                      imageSelectorCamera(inContext);
                    }),
                SpeedDialChild(
                    child: Icon(Icons.image),
                    label: "Gallery",
                    onTap: () {
                      imageSelectorGallery(inContext);
                    })
              ],
            ),
            body: GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: documentsModel.entityList.length,
              itemBuilder: (BuildContext context, int inIndex) {
                Document document = documentsModel.entityList[inIndex];
                var offset = inIndex + 1;
                var nameMsg;
                var docPath;
                try {
                  docPath = document.path;
                  nameMsg = document.path.split('/').last;
                } catch (Exception) {
                  nameMsg = "This error appear because path is null or DB is corrupt";
                  docPath = "This error appear because path is null or DB is corrupt";
                }
                final String name = 'File $offset: $nameMsg';
                var fileExtension = document.path.split('.')[1];
                var imageIndex = 0;
                switch (fileExtension) {
                  case 'png':
                  case 'jpg':
                  case 'bmp':
                    imageIndex = 2;
                    break;
                  case 'mp3':
                  case 'm4a':
                  case 'ogg':
                  case 'flac':
                  case 'webm':
                  case 'wma':
                    imageIndex = 1;
                    break;
                  case 'gif':
                  case 'flv':
                  case 'mp4':
                  case 'mpg':
                  case 'mpeg':
                  case '3gp':
                    imageIndex = 3;
                    break;
                  default:
                    imageIndex = 0;
                }
                print(imageIndex);
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
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
                          _openFileExplorer(inContext, false, inIndex);
                        })
                  ],
                  child: new Container(
                    color: Colors.lightBlueAccent,
                    margin: const EdgeInsets.all(10.0),
                    child: new ListTile(
                      isThreeLine: true,
                      onLongPress: () {
                        _openFileExplorer(inContext, false, inIndex);
                      },
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
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: new Text(
                        docPath,
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }));
  }

  /// Save to the database.
  /// TODO
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The NotesModel.
  void _edit(BuildContext inContext, DocumentsModel inDocumentModel, int index) async {
    inDocumentModel.entityBeingEdited.id = index + 1;
    print("-- DocumentList.edit()");
    print("-- DocumentList._edit(): Path - ${inDocumentModel.entityBeingEdited}");
    if (inDocumentModel.entityBeingEdited.id != null) {
      print("-- DocumentsList._edit(): Creating: ${inDocumentModel.entityBeingEdited}");
      await DocumentsDBWorker.db.update(documentsModel.entityBeingEdited);
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
    print("-- DocumentList._save() - ${inDocumentModel.path}");
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
    var deleteText;
    try {
      deleteText = inDocument.path.split('/').last;
    } catch (Exception) {
      deleteText = "This error appear because path is null or DB is corrupt";
    }

    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
              title: Text("Delete Document"),
              content: Text("Are you sure you want to delete $deleteText}?"),
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
