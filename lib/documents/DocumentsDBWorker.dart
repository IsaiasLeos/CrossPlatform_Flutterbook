import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

import "../utils.dart" as utils;
import "DocumentsModel.dart";

/// Database provider class for documents.
class DocumentsDBWorker {
  /// Static instance and private constructor
  DocumentsDBWorker._();

  static final DocumentsDBWorker db = DocumentsDBWorker._();

  /// Database instance
  Database _db;

  /// Get database instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {
    if (_db == null) {
      _db = await init();
    }

    print("-- document DocumentsDBWorker.get-database(): _db = $_db");

    return _db;
  }

  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {
    print("-- document DocumentDBWorker.init()");

    String currentPath = join(utils.docsDir.path, "documents.db");
    print("-- document DocumentDBWorker.init(): path = $currentPath");
    Database db = await openDatabase(currentPath, version: 1, onOpen: (db) {},
        onCreate: (Database inDB, int inVersion) async {
          await inDB.execute("CREATE TABLE IF NOT EXISTS documents ("
              "id INTEGER PRIMARY KEY,"
              "path TEXT"
              ")");
        });
    return db;
  }

  /// Create a document from a Map.
  Document documentFromMap(Map inMap) {
    print("-- document DocumentDBWorker.documentFromMap(): inMap = $inMap");

    Document document = Document();
    document.id = inMap["id"];
    document.path = inMap["path"];

    print("-- document DocumentDBWorker.documentFromMap(): document = $document");

    return document;
  }

  /// Create a Map from a document.
  Map<String, dynamic> documentToMap(Document document) {
    print("-- document DocumentDBWorker.documentToMap(): inDocument = $document");

    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = document.id;
    map["path"] = document.path;

    print("-- document DocumentDBWorker.documentToMap(): map = $map");

    return map;
  }

  /// Create a document.
  ///
  /// @param  inDocument The Document object to create.
  /// @return        Future.
  Future create(Document inDocument) async {
    print("-- document DocumentDBWorker.create(): inDocument = $inDocument");

    Database db = await database;

    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM documents");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    // Insert into table.
    return await db.rawInsert(
        "INSERT INTO documents (id, path) VALUES (?, ?)",
        [id, inDocument.path]);
  }

  /// Get a specific document.
  ///
  /// @param  inID The ID of the document to get.
  /// @return      The corresponding document object.
  Future<Document> get(int inID) async {
    print("-- document DocumentsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("documents", where: "id = ?", whereArgs: [inID]);

    print("-- document DocumentDBWorker.get(): rec.first = $rec.first");

    return documentFromMap(rec.first);
  }

  /// Get all documents.
  ///
  /// @return A List of documents objects.
  Future<List> getAll() async {
    print("-- document DocumentsDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("documents");
    var list = recs.isNotEmpty ? recs.map((m) => documentFromMap(m)).toList() : [];

    print("-- document DocumentsDBWorker.getAll(): list = $list");

    return list;
  }

  /// Update a documents.
  ///
  /// @param  inDocument The documents to update.
  /// @return        Future.
  Future update(Document inDocument) async {
    print("-- document DocumentDBWorker.update(): inDocument = $inDocument");

    Database db = await database;
    return await db.update("document", documentToMap(inDocument), where: "id = ?", whereArgs: [inDocument.id]);
  }

  /// Delete a documents.
  ///
  /// @param  inID The ID of the documents to delete.
  /// @return      Future.
  Future delete(int inID) async {
    print("-- document DocumentDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("documents", where: "id = ?", whereArgs: [inID]);
  }
}
