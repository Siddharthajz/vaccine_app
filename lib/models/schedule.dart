import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 0)
class Schedule{
  @HiveField(0)
  final String childDOB;
  @HiveField(1)
  final String vaccineID;
  @HiveField(2)
  final String doseID;
  @HiveField(3)
  final String doseLabel;
  @HiveField(4)
  final DateTime dueDate;
  @HiveField(5)
  final bool isDoseGiven;
  @HiveField(6)
  final bool isUserSelected;

  Schedule(this.childDOB, this.vaccineID, this.doseID, this.doseLabel, this.dueDate, this.isDoseGiven, this.isUserSelected);

}