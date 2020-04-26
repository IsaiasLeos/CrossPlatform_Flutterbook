import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

import '../utils.dart' as utils;
import 'DocumentsModel.dart';

/// Database provider class for Documents.
class DocumentsDBWorker {
  /// Static instance and private constructor
  DocumentsDBWorker._();

  static final DocumentsDBWorker db = DocumentsDBWorker._();

  /// The database instance.
  Database _db;

  /// Get database instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {
    if (_db == null) {
      _db = await init();
    }

    print("-- Documents DocumentsDBWorker.get-database() = $_db");

    return _db;
  }

  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {
    print("-- Documents DocumentsDBWorker.init()");

    String path = join(utils.docsDir.path, "documents.db");
    print("-- Documents DocumentsDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
      await inDB.execute("CREATE TABLE IF NOT EXISTS documents ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "content TEXT,"
          "color TEXT"
          ")");
    });
    return db;
  }

  /// Create a document from a Map.
  Document documentsFromMap(Map inMap) {
    print("-- Documents DocumentsDBWorker.documentFromMap(): inMap = $inMap");

    Document documents = Document();
    documents.id = inMap["id"];
    documents.title = inMap["title"];
    documents.content = inMap["content"];
    documents.color = inMap["color"];

    print("#-- Documents DocumentsDBWorker.documentFromMap(): document = $documents");

    return documents;
  }

  /// Create a Map from a document.
  Map<String, dynamic> documentsToMap(Document inDocument) {
    print("-- Documents DocumentsDBWorker.documentToMap() = $inDocument");

    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inDocument.id;
    map["title"] = inDocument.title;
    map["content"] = inDocument.content;
    map["color"] = inDocument.color;

    print("-- Documents DocumentsDBWorker.documentToMap(): map = $map");

    return map;
  }

  /// Create a document.
  ///
  /// @param  inDocument The document object to create.
  /// @return        Future.
  Future create(Document inDocument) async {
    print("-- Documents DocumentsDBWorker.create(): inDocument = $inDocument");

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM documents");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    // Insert into table.
    return await db.rawInsert("INSERT INTO documents (id, title, content, color) VALUES (?, ?, ?, ?)",
        [id, inDocument.title, inDocument.content, inDocument.color]);
  }

  /// Get a specific document.
  ///
  /// @param  inID The ID of the document to get.
  /// @return      The corresponding document object.
  Future<Document> get(int inID) async {
    print("-- Documents DocumentsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("documents", where: "id = ?", whereArgs: [inID]);

    print("-- Documents DocumentsDBWorker.get(): rec.first = $rec.first");

    return documentsFromMap(rec.first);
  }

  /// Get all document.
  ///
  /// @return A List of document objects.
  Future<List> getAll() async {
    print("-- Document DocumentDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("documents");
    var list = recs.isNotEmpty ? recs.map((m) => documentsFromMap(m)).toList() : [];

    print("-- Document DocumentDBWorker.getAll(): list = $list");

    return list;
  }

  /// Update a document.
  ///
  /// @param inDocument The document to update.
  /// @return       Future.
  Future update(Document inDocument) async {
    print("-- Document DocumentDBWorker.update(): inDocument = $inDocument");

    Database db = await database;
    return await db.update("document", documentsToMap(inDocument),
        where: "id = ?", whereArgs: [inDocument.id]);
  }

  /// Delete a document.
  ///
  /// @param inID The ID of the document to delete.
  /// @return     Future.
  Future delete(int inID) async {
    print("-- Document DocumentDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("document", where: "id = ?", whereArgs: [inID]);
  }
}
