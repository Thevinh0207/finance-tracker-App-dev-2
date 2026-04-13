class Goal {
  int? goalID;
  String goalName;
  double goalAmount;
  double currentAmount;
  String date;
  String goalType;
  String? userID;

  Goal({
    required this.goalID,
    required this.goalName,
    required this.goalAmount,
    required this.currentAmount,
    required this.date,
    required this.goalType,
    required this.userID,
  });

  Goal.noGoalIdConstructor({
    required this.goalName,
    required this.goalAmount,
    required this.currentAmount,
    required this.date,
    required this.goalType,
    required this.userID,
  });

  Map<String, dynamic> toMap() {
    return {
      'goalID': goalID,
      'goalName': goalName,
      'goalAMount': goalAmount,
      'currentAmount': currentAmount,
      'date': date,
      'goalType': goalType,
      'userID': userID,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map){
    return Goal(
      goalID: map['goalID'],
      goalName: map['goalName'],
      goalAmount: map['goalAmount'],
      currentAmount: map['currentAmount'],
      date: map['date'],
      goalType: map['goalType'],
      userID: map['userID']
    );
  }
}
