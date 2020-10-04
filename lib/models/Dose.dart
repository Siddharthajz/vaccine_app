class Dose {
    final String label;
    final String doseID;
    final int startDate;
    final int endDate;
    final String vaccineID;
    final String givenDate;
    final String doctorName;
    final String notes;

    Dose({this.label, this.doseID, this.startDate, this.endDate, this.vaccineID, this.givenDate, this.doctorName, this.notes});

    static Dose fromMap(Map<String, dynamic> map) {
        if (map == null) return null;
        return Dose(
            label: map['label'],
            doseID: map['doseID'],
            startDate: map['startDate'],
            endDate: map["endDate"],
            vaccineID: map['vaccineID'],
            givenDate: map['givenDate'],
            doctorName: map['doctorName'],
            notes: map['notes'],
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'label': label,
            'doseID': doseID,
            'startDate': startDate,
            'endDate': endDate,
            'vaccineID': vaccineID,
            'givenDate': givenDate,
            'doctorName': doctorName,
            'notes': notes,
        };
    }
}