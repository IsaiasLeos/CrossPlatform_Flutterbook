import 'dart:io';

import '../BaseModel.dart';

class Document {
  int id;
  String title;
  File content;
  String color;

  /// Debug
  String toString() {
    return "{ id=$id, title=$title, color=$color }";
  }
}

/// The model backing this entity type's views.
class DocumentsModel extends BaseModel {
  String color;

  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.
  void setColor(String inColor) {
    print("-- DocumentModel.setColor(): inColor = $inColor");

    color = inColor;
    notifyListeners();
  }
}

DocumentsModel documentsModel = DocumentsModel();
