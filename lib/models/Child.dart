import 'Vaccine.dart';

class Child {
    final String uid;
    final String fname;
    final String surname;
    final String dob;
    final String gender;
    final String documentID;
    final Vaccine vaccines;

    Child({this.documentID, this.gender, this.vaccines, this.uid, this.fname, this.surname, this.dob});

    static Child fromMap(Map<String, dynamic> map, String documentID) {
        if (map == null) return null;
        return Child(
            uid: map['uid'],
            fname: map['firstName'],
            surname: map["lastName"],
            dob: map['dob'],
            gender: map['gender'],
            documentID: documentID,
            vaccines: Vaccine.fromMap(map['vaccines'], documentID),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'uid': uid,
            'fname': fname,
            'surname': surname,
            'dob': dob,
            'gender': gender,
            'vaccines': vaccines,
        };
    }
}