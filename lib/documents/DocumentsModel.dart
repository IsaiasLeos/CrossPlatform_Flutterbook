import '../BaseModel.dart';

class Document {
  int id;
  String path;

  /// Debug
  String toString() {
    return "{ id=$id, path=$path, }";
  }
}

/// The model backing this entity type's views.
class DocumentsModel extends BaseModel {
  String path;

  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.
  void setPath(String inPath) {
    print("-- DocumentModel.setPath(): inPath = $inPath");

    path = inPath;
    notifyListeners();
  }
}

DocumentsModel documentsModel = DocumentsModel();
