import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inclasswork/audionotes/DocumentsDBWorker.dart';
import 'package:inclasswork/audionotes/DocumentsModel.dart';
import 'package:open_file/open_file.dart';
import 'package:scoped_model/scoped_model.dart';

/// The Document List sub-screen.
class DocumentsList extends StatefulWidget {
  _DocumentsListState createState() => new _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(
            type: _pickingType,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      }
    } on Exception catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName =
          _path != null ? _path.split('/').last : _paths != null ? _paths.keys.toString() : '...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<DocumentsModel>(
        model: documentsModel,
        child: ScopedModelDescendant<DocumentsModel>(
            builder: (BuildContext inContext, Widget inChild, DocumentsModel inModel) {
          return new Scaffold(
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    _multiPick = true;
                    _openFileExplorer();
                  }),
              body: Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: new SingleChildScrollView(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Builder(
                        builder: (BuildContext context) => _loadingPath
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: const CircularProgressIndicator())
                            : _path != null || _paths != null
                                ? new Container(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    height: MediaQuery.of(context).size.height * 0.50,
                                    child: new Scrollbar(
                                        child: new ListView.separated(
                                      itemCount:
                                          _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                                      itemBuilder: (BuildContext context, int index) {
                                        var offset = index + 1;
                                        print("-- DocumentList.build(): offset = $offset");
                                        final bool isMultiPath =
                                            _paths != null && _paths.isNotEmpty;
                                        final String name = 'File $index: ' +
                                            (isMultiPath
                                                ? _paths.keys.toList()[index]
                                                : _fileName ?? '...');
                                        final path = isMultiPath
                                            ? _paths.values.toList()[index].toString()
                                            : _path;
                                        return Slidable(
                                          delegate: SlidableDrawerDelegate(),
                                          actionExtentRatio: .25,
                                          secondaryActions: [
                                            IconSlideAction(
                                                caption: "Delete",
                                                color: Colors.red,
                                                icon: Icons.delete,
                                                onTap: () {}),
                                            IconSlideAction(
                                                caption: "Edit",
                                                color: Colors.green,
                                                icon: Icons.edit,
                                                onTap: () {})
                                          ],
                                          child: new ListTile(
                                            onTap: () {
                                              Future<void> openFile() async {
                                                var currentPath = _paths.values.toList();
                                                print("-- Path: ${currentPath[index]}");
                                                await OpenFile.open(currentPath[index]);
                                              }

                                              openFile();
                                            },
                                            title: new Text(
                                              name,
                                            ),
                                            subtitle: new Text(path),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (BuildContext context, int index) =>
                                          new Divider(),
                                    )),
                                  )
                                : new Container(),
                      ),
                    ],
                  ),
                ),
              ));
        }));
  }

  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext The BuildContext of the parent Widget.
  /// @param  inNote    The note (potentially) being deleted.
  /// @return           Future.
  Future _deleteNote(BuildContext inContext, Document inDocument) async {
    print("-- NotestList._deleteNote(): inNote = $inDocument");

    return showDialog(
        context: inContext,
        barrierDismissible: false,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
              title: Text("Delete Note"),
              content: Text("Are you sure you want to delete ${inDocument.title}?"),
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
                          content: Text("Note deleted")));
                      // Reload data from database to update list.
                      documentsModel.loadData("notes", DocumentsDBWorker.db);
                    })
              ]);
        });
  }
}
