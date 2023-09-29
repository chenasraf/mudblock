class Variable {
  String name;
  String value;

  Variable(this.name, this.value);
  Variable.empty()
      : name = '',
        value = '';

  factory Variable.fromJson(Map<String, dynamic> json) => Variable(
        json['name'],
        json['value'],
      );
  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };

  Variable copyWith({
    String? name,
    String? value,
  }) =>
      Variable(
        name ?? this.name,
        value ?? this.value,
      );
}
