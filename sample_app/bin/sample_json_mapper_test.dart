library sample_json_mapper_test;

import "package:portable_mirror/mirror_dynamic_lib.dart";
import "../lib/src/models.dart"; 
import "../lib/src/sample_json_mapper.dart";

Expense createExpense() =>
  new Expense.Default()
  ..id = "aaa"
  ..rev = "mmm"
  ..amount = 111
  ..date = new DateTime.now()
  ..detail = "asdjah"
  ..isClaimed = true
  ..expenseType = const ExpenseType("Hotel", "HT");

String json1 = '{"id": "aaa","rev": "mmm","expenseType": {"name": "Hotel", "code": "HT"},"date": "2013-10-01 21:54:10.972","amount": 111,"detail": "asdjah","isClaimed": true}';
String json2 = '{"id": "aaa1","rev": "mmm","expenseType": {"name": "Hotel", "code": "HT"},"date": "2013-10-01 21:54:10.972","amount": 111,"detail": "asdjah","isClaimed": true}';

String test_toJson(Object obj) {
  String json = sampleJsonMapper.toJson(obj);
  print(">> json: ${json}");
  return json;
}

Object test_fromJson(String json) {
  Object obj = sampleJsonMapper.fromJson(Expense, json);
  print(">> obj: ${obj}");
  return obj;
}

test_json_mapper() {
  // register reflection factory
  initClassMirrorFactory();
  {
    print(">>1 test_toJson");
    String json = test_toJson(createExpense());
  
    print(">>1 test_fromJson");
    Expense e = test_fromJson(json);
  }
  {
    print(">>2 test_fromJson");
    Expense e = test_fromJson(json1);
   
    print(">>2 test_toJson");
    String json = test_toJson(e);
  }  
  {
    print(">>3 test_fromJson");
    List<Expense> es = test_fromJson('[${json1},${json2}]');
   
    print(">>3 test_toJson");
    String json = test_toJson(es);
  }

}

main() {
  test_json_mapper();
}
