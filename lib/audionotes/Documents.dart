import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";

import 'DocumentsDBWorker.dart';
import 'DocumentsEntry.dart';
import 'DocumentsList.dart';
import 'DocumentsModel.dart';

/// The Document screen.
class Documents extends StatelessWidget {
  /// Constructor.
  Documents() {
    print("-- Document.constructor");
    documentsModel.loadData("documents", DocumentsDBWorker.db);
  }

  Widget build(BuildContext inContext) {
    print("-- Documents.build()");

    return ScopedModel<DocumentsModel>(
        model: documentsModel,
        child: ScopedModelDescendant<DocumentsModel>(
            builder: (BuildContext inContext, Widget inChild, DocumentsModel inModel) {
          return IndexedStack(
              index: inModel.stackIndex, children: [DocumentsList(), DocumentsEntry()]);
        }));
  }
}
