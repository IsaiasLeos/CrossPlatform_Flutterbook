import '../BaseModel.dart';

class Appointment {
  /// The fields this entity type contains.
  int id;
  String title;
  String description;
  String apptDate; // YYYY,MM,DD
  String apptTime; // HH,MM

  /// Debugging
  String toString() {
    return "{ id=$id, title=$title, description=$description, apptDate=$apptDate, apptDate=$apptTime }";
  }
}

/// The model backing this entity type's views.
class AppointmentsModel extends BaseModel {
  /// The appointment time.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  String apptTime;

  /// For display of the appointment time chosen by the user.
  ///
  /// @param inApptTime The appointment date in HH:MM form.
  void setApptTime(String inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}

// The instance of this model.
AppointmentsModel appointmentsModel = AppointmentsModel();
