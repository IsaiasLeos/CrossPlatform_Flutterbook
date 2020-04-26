import '../BaseModel.dart';

class Note {
  int id;
  String title;
  String content;
  String color;

  /// Debug
  String toString() {
    return "{ id=$id, title=$title, content=$content, color=$color }";
  }
}

/// The model backing this entity type's views.
class NotesModel extends BaseModel {
  String color;

  /// For display of the color chosen by the user.
  ///
  /// @param inColor The color.
  void setColor(String inColor) {
    print("-- NotesModel.setColor(): inColor = $inColor");

    color = inColor;
    notifyListeners();
  }
}

NotesModel notesModel = NotesModel();
