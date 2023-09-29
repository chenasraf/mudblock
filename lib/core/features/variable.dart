class Variable<T> {
  String name;
  VariableType type;
  String strValue;

  Variable(this.name, this.type, this.strValue);
  Variable.empty()
      : type = VariableType.string,
        name = '',
        strValue = '';
  Variable.string(this.name, this.strValue) : type = VariableType.string;
  Variable.number(this.name, this.strValue) : type = VariableType.number;
  Variable.boolean(this.name, this.strValue) : type = VariableType.boolean;

  T get value {
    switch (type) {
      case VariableType.string:
        return strValue as T;
      case VariableType.number:
        return double.parse(strValue) as T;
      case VariableType.boolean:
        return (strValue == 'true') as T;
    }
  }

  set value(T value) {
    switch (type) {
      case VariableType.string:
        strValue = value as String;
        break;
      case VariableType.number:
        strValue = (value as double).toString();
        break;
      case VariableType.boolean:
        strValue = (value as bool).toString();
        break;
    }
  }

  factory Variable.fromJson(Map<String, dynamic> json) {
      // TODO generalize getting enum from string
    switch (VariableType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => VariableType.string,
    )) {
      case VariableType.string:
        return Variable.string(json['name'], json['value']);
      case VariableType.number:
        return Variable.number(json['name'], json['value']);
      case VariableType.boolean:
        return Variable.boolean(json['name'], json['value']);
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'value': strValue,
      };

  Variable copyWith<T>({
    String? name,
    VariableType? type,
    String? strValue,
  }) =>
      Variable(
        name ?? this.name,
        type ?? this.type,
        strValue ?? this.strValue,
      );
}

class StringVariable extends Variable<String> {
  StringVariable(String name, String value) : super.string(name, value);
  StringVariable.fromJson(Map<String, dynamic> json)
      : super(json['name'], VariableType.values[json['type']], json['value']);
}

class NumberVariable extends Variable<double> {
  NumberVariable(String name, double value)
      : super.number(name, value.toString());
  NumberVariable.fromJson(Map<String, dynamic> json)
      : super(json['name'], VariableType.values[json['type']], json['value']);
}

class BooleanVariable extends Variable<bool> {
  BooleanVariable(String name, bool value)
      : super.boolean(name, value.toString());
  BooleanVariable.fromJson(Map<String, dynamic> json)
      : super(json['name'], VariableType.values[json['type']], json['value']);
}

enum VariableType { string, number, boolean }

