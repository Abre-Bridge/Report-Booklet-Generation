import '../models/ue.dart';

class GpaResult {
  final double gpaItemLevel;
  final String grade;

  GpaResult(this.gpaItemLevel, this.grade);
}

class GpaCalculator {
  static GpaResult getGradeAndGpa(double mark) {
    if (mark >= 80 && mark <= 100) return GpaResult(4.0, 'A');
    if (mark >= 75 && mark < 80) return GpaResult(3.7, 'A-');
    if (mark >= 70 && mark < 75) return GpaResult(3.3, 'B+');
    if (mark >= 65 && mark < 70) return GpaResult(3.0, 'B');
    if (mark >= 60 && mark < 65) return GpaResult(2.7, 'B-');
    if (mark >= 55 && mark < 60) return GpaResult(2.3, 'C+');
    if (mark >= 50 && mark < 55) return GpaResult(2.0, 'C');
    if (mark >= 45 && mark < 50) return GpaResult(1.7, 'C-');
    if (mark >= 40 && mark < 45) return GpaResult(1.3, 'D');
    if (mark >= 35 && mark < 40) return GpaResult(1.0, 'D-');
    if (mark >= 0 && mark < 35) return GpaResult(0.0, 'E');
    return GpaResult(0.0, 'N/A'); // fallback
  }

  static double calculateOverallGpa(List<UE> ues) {
    if (ues.isEmpty) return 0.0;

    double totalQualityPoints = 0;
    int totalCredits = 0;

    for (var ue in ues) {
      double itemGpa = getGradeAndGpa(ue.mark).gpaItemLevel;
      totalQualityPoints += (itemGpa * ue.credits);
      totalCredits += ue.credits;
    }

    if (totalCredits == 0) return 0.0;
    return totalQualityPoints / totalCredits;
  }

  static String getRanking(double gpa) {
    if (gpa >= 3.7) return 'Gold 🏆';
    if (gpa >= 3.0) return 'Silver 🥈';
    if (gpa >= 2.0) return 'Bronze 🥉';
    return 'Participant 🔰';
  }
}
