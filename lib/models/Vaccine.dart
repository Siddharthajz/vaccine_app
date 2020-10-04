import 'Dose.dart';

class Vaccine {
    final String vaccineID;
    final String name;
    final String description;
    final String methodOfInjection;
    final String protectsAgainst;
    final bool recommendedByCDC;
    final bool recommendedByIndiaGov;
    final String siteOfInjection;
    final Dose doses;
    final bool userSelected;

    Vaccine({this.userSelected, this.vaccineID, this.name, this.description, this.methodOfInjection, this.protectsAgainst, this.recommendedByCDC, this.recommendedByIndiaGov, this.siteOfInjection, this.doses});

    static Vaccine fromMap(Map<String, dynamic> map, String vaccineID) {
        if (map == null) return null;
        return Vaccine(
            vaccineID: vaccineID,
            name: map['name'],
            description: map['description'],
            methodOfInjection: map["methodOfInjection"],
            protectsAgainst: map['protectsAgainst'],
            recommendedByCDC: map['recommendedByCDC'],
            recommendedByIndiaGov: map['recommendedByIndiaGov'],
            siteOfInjection: map['siteOfInjection'],
            userSelected: map['userSelected'],
            doses: Dose.fromMap(map['vaccines']),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            "vaccineID": vaccineID,
            "name": name,
            "description": description,
            "methodOfInjection": methodOfInjection,
            "protectsAgainst": protectsAgainst,
            "recommendedByCDC": recommendedByCDC,
            "recommendedByIndiaGov": recommendedByIndiaGov,
            "siteOfInjection": siteOfInjection,
            "userSelected": userSelected,
            "doses": doses,
        };
    }

}