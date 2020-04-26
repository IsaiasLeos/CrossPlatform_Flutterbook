import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";

import 'ContactsDBWorker.dart';
import 'ContactsEntry.dart';
import 'ContactsList.dart';
import 'ContactsModel.dart';

/// The Contacts screen.
class Contacts extends StatelessWidget {
  /// Constructor.
  Contacts() {
    print("-- Contacts.constructor");

    // Initial load of data.
    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {
    print("-- Contacts.build()");

    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
            builder: (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return IndexedStack(
              index: inModel.stackIndex,
              children: [ContactsList(), ContactsEntry()] /* End IndexedStack children. */
              );
        }));
  }
}
