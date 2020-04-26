import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

import '../utils.dart' as utils;
import 'AudioNotesModel.dart';

/// Database provider class for audionotes.
class AudioNotesDBWorker {
  /// Static instance and private constructor
  AudioNotesDBWorker._();

  static final AudioNotesDBWorker db = AudioNotesDBWorker._();

  /// The database instance.
  Database _db;

  /// Get database instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {
    if (_db == null) {
      _db = await init();
    }

    print("-- AudioNotes AudioNotesDBWorker.get-database() = $_db");

    return _db;
  }

  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {
    print("-- AudioNotes AudioNotesDBWorker.init()");

    String path = join(utils.docsDir.path, "audionotes.db");
    print("-- AudioNotes AudioNotesDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS audionotes ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "content TEXT,"
          "color TEXT"
          ")");
    });
    return db;
  }

  /// Create a Note from a Map.
  AudioNote audioNoteFromMap(Map inMap) {
    print("-- AudioNotes AudioNotesDBWorker.noteFromMap(): inMap = $inMap");

    AudioNote audionote = AudioNote();
    audionote.id = inMap["id"];
    audionote.title = inMap["title"];
    audionote.content = inMap["content"];
    audionote.color = inMap["color"];

    print("#-- AudioNotes AudioNotesDBWorker.noteFromMap(): note = $audionote");

    return audionote;
  }

  /// Create a Map from a Note.
  Map<String, dynamic> audioNoteToMap(AudioNote inAudioNote) {
    print("-- AudioNotes AudioNotesDBWorker.noteToMap() = $inAudioNote");

    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inAudioNote.id;
    map["title"] = inAudioNote.title;
    map["content"] = inAudioNote.content;
    map["color"] = inAudioNote.color;

    print("-- audionotes AudioNotesDBWorker.noteToMap(): map = $map");

    return map;
  }

  /// Create a note.
  ///
  /// @param  inNote The Note object to create.
  /// @return        Future.
  Future create(AudioNote inAudioNote) async {
    print("-- AudioNotes AudioNotesDBWorker.create(): inNote = $inAudioNote");

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    // Insert into table.
    return await db.rawInsert("INSERT INTO notes (id, title, content, color) VALUES (?, ?, ?, ?)",
        [id, inAudioNote.title, inAudioNote.content, inAudioNote.color]);
  }

  /// Get a specific note.
  ///
  /// @param  inID The ID of the note to get.
  /// @return      The corresponding Note object.
  Future<AudioNote> get(int inID) async {
    print("-- AudioNotes AudioNotesDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("audionotes", where: "id = ?", whereArgs: [inID]);

    print("-- AudioNotes AudioNotesDBWorker.get(): rec.first = $rec.first");

    return audioNoteFromMap(rec.first);
  }

  /// Get all notes.
  ///
  /// @return A List of Note objects.
  Future<List> getAll() async {
    print("-- AudioNotes AudioNotesDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("audionotes");
    var list = recs.isNotEmpty ? recs.map((m) => audioNoteFromMap(m)).toList() : [];

    print("-- AudioNotes AudioNotesDBWorker.getAll(): list = $list");

    return list;
  }

  /// Update a note.
  ///
  /// @param inNote The note to update.
  /// @return       Future.
  Future update(AudioNote inAudioNote) async {
    print("-- AudioNotes AudioNotesDBWorker.update(): inNote = $inAudioNote");

    Database db = await database;
    return await db
        .update("audionotes", audioNoteToMap(inAudioNote), where: "id = ?", whereArgs: [inAudioNote.id]);
  }

  /// Delete a note.
  ///
  /// @param inID The ID of the note to delete.
  /// @return     Future.
  Future delete(int inID) async {
    print("-- AudioNotes AudioNotesDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("audionotes", where: "id = ?", whereArgs: [inID]);
  }
}
