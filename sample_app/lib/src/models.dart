library ExpenseModels;

class Expense  {
  String _id = null;
  String _rev = null;
  ExpenseType _type;
  DateTime _date;
  num _amount = 0;
  String _detail;
  bool _isClaimed = false;
  
  Expense(this._id, this._rev, this._type, this._date, this._amount, this._detail, this._isClaimed);
  
  static int _gid = 0;
  factory Expense.random() {
    return new Expense("id-${_gid++}", "1", null, new DateTime.now(), _gid++, "??", true);
  }
  // shoudl be always defined.. ??
  factory Expense.Default() {
    return new Expense(null, null, null, null, null, null, null);
  }
  
  String get id => _id;
  void set id(String i) { _id = i; }
  
  String get rev => _rev;
  void set rev(String value) { _rev = value; }
  
  ExpenseType get expenseType => _type;
  void set expenseType(ExpenseType i) { _type = i; }
  
  DateTime get date => _date;
  void set date(DateTime i) { _date = i; }
  
  num get amount => _amount;
  void set amount(num i) { _amount = i; }
  
  String get detail => _detail;
  void set detail(String i) { _detail = i; }
  
  bool get isClaimed => _isClaimed;
  void set isClaimed(bool i) { _isClaimed = i; }
  
  String toString() => "Expense(${id}, ${rev}, ${expenseType}, ${date}, ${amount}, ${detail}, ${isClaimed})";
}

/// Used to list the type of expenses
class ExpenseType {
  final String name;
  final String code;

  const ExpenseType(this.name, this.code);

  toString() {
    return "${super.toString()}: $name, $code";
  }

  bool operator ==(other) {
    if (other == null) return false;
    return this.name == other.name && this.code == other.code;
  }
  int get hashCode =>this.name.hashCode*this.name.hashCode;
  toMap() {
    var map = new Map<String,String>();
    map["name"] = name;
    map["code"] = code;
    return map;
  }
}

