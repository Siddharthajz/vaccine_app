class Parent {
    final String uid;
    final String fname;
    final String surname;
    final String email;
    final String dob;
    final String selectedChild;

    Parent({this.selectedChild, this.uid, this.fname, this.surname, this.email, this.dob});

    Parent.fromData(Map<String, dynamic> data)
        : uid = data['uid'],
            fname = data['fname'],
            surname = data["surname"],
            email = data['email'],
            dob = data['dob'],
            selectedChild = data['selectedChild'];

    Map<String, dynamic> toMap() {
        return {
            'uid': uid,
            'fname': fname,
            'surname': surname,
            'email': email,
            'dob': dob,
            'selectedChild': selectedChild,
        };
    }
}