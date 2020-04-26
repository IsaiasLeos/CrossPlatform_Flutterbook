import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";

import 'AudioNotesDBWorker.dart';
import 'AudioNotesEntry.dart';
import 'AudioNotesList.dart';
import 'AudioNotesModel.dart';

/// The Notes screen.
class AudioNotes extends StatelessWidget {
  /// Constructor.
  AudioNotes() {
    print("-- AudioNotes.constructor");
    audioNotesModel.loadData("audionotes", AudioNotesDBWorker.db);
  }

  Widget build(BuildContext inContext) {
    print("-- AudioNotes.build()");

    return ScopedModel<AudioNotesModel>(
        model: audioNotesModel,
        child: ScopedModelDescendant<AudioNotesModel>(
            builder: (BuildContext inContext, Widget inChild, AudioNotesModel inModel) {
          return IndexedStack(
              index: inModel.stackIndex, children: [AudioNotesList(), AudioNotesEntry()]);
        }));
  }
}
