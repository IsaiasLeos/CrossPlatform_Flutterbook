import '../BaseModel.dart';

class Contact {
  /// The fields this entity type contains.
  int id;
  String name;
  String phone;
  String email;
  String birthday; // YYYY,MM,DD

  /// Debugging
  String toString() {
    return "{ id=$id, name=$name, phone=$phone, email=$email, birthday=$birthday }";
  }
}

/// The model backing this entity type's views
class ContactsModel extends BaseModel {
  /// "Force" a rebuild of the entry page (when selecting an avatar image).
  void triggerRebuild() {
    print("-- ContactsModel.triggerRebuild()");

    notifyListeners();
  }
}

// The instance of this model.
ContactsModel contactsModel = ContactsModel();
