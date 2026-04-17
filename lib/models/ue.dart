class UE {
  String name;
  double mark;
  int credits;

  UE({
    required this.name,
    required this.mark,
    required this.credits,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mark': mark,
      'credits': credits,
    };
  }

  factory UE.fromJson(Map<String, dynamic> json) {
    return UE(
      name: json['name'],
      mark: json['mark'],
      credits: json['credits'],
    );
  }
}
