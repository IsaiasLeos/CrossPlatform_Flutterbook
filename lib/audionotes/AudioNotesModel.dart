import 'package:assets_audio_player/playable.dart';

import '../BaseModel.dart';

class AudioNote {
  Audio audio;
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
class AudioNotesModel extends BaseModel {
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

AudioNotesModel audioNotesModel = AudioNotesModel();
