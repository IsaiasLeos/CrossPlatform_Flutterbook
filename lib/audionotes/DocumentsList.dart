import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";

import 'DocumentsModel.dart' show Document, DocumentsModel, documentsModel;

/// The Document List sub-screen.
class DocumentsList extends StatelessWidget {
  Widget build(BuildContext inContext) {
    print("-- DocumentList.build()");
    return ScopedModel<DocumentsModel>(
        model: documentsModel,
        child: ScopedModelDescendant<DocumentsModel>(
            builder: (BuildContext inContext, Widget inChild, DocumentsModel inModel) {
          return Scaffold(
            // Add Document.
            floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white), onPressed: () async {}),
            body: ListView.builder(
                itemCount: documentsModel.entityList.length,
                itemBuilder: (BuildContext inBuildContext, int inIndex) {
                  Document document = documentsModel.entityList[inIndex];
                  // Determine document background color, default is white
                  Color color = Colors.white;
                  switch (document.color) {
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
                                  title: Text("${document.title}"),
                                  subtitle: Text("${document.content}"),
                                  // Edit existing document.
                                  onTap: () async {}))));
                }),
          );
        }));
  }
}
