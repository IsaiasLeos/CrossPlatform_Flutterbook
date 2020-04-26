import "package:scoped_model/scoped_model.dart";

class BaseModel extends Model {
  /// Which page is currently showing.
  int stackIndex = 0;

  /// The list of entities.
  List entityList = [];

  /// The entity being edited.
  var entityBeingEdited;

  /// The date chosen by the user.
  String chosenDate;

  /// For display of the date chosen by the user.
  ///
  /// @param inDate The date in MM/DD/YYYY form.
  void setChosenDate(String inDate) {
    print("-- BaseModel.setChosenDate(): inDate = $inDate");

    chosenDate = inDate;
    notifyListeners();
  }

  /// Load data from database.
  ///
  /// @param inEntityType The type of entity being loaded ("appointments", "contacts", "notes" or "tasks").
  /// @param inDatabase   The DBProvider.db instance for the entity.
  void loadData(String inEntityType, dynamic inDatabase) async {
    print("-- ${inEntityType}Model.loadData()");

    // Load entities from database.
    entityList = await inDatabase.getAll();
    notifyListeners();
  }

  /// For navigating between entry and list views.
  ///
  /// @param inStackIndex The stack index to make current.
  void setStackIndex(int inStackIndex) {
    print("-- BaseModel.setStackIndex(): inStackIndex = $inStackIndex");

    stackIndex = inStackIndex;
    notifyListeners();
  }
}
