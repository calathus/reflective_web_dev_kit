part of sample_json_mapper_test;

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

Object test_fromJson(Type type, String json) {
  Object obj = sampleJsonMapper.fromJson(type, json);
  print(">> obj: ${obj}");
  return obj;
}

test_simple_model() {
    {
      A a = new A.create()..i = 10
        ..bs.add(new B.create()..s = "vvv")
        ..bs.add(new B.create()..s = "eee");
      
      String json = test_toJson(a);
      print(">>A@1 test_toJson json: ${json}");
      
      A a1 = test_fromJson(A, json);
      print(">>A@2 test_Json a1: ${a1}");
    }
    
    {
      A a = new A(10, [new B("ss"), new B("vv")]);
      String json = test_toJson(a);
      print(">>B@1 test_toJson json: ${json}");
    
      A a1 = test_fromJson(A, json);
      print(">>B@2 test_Json a1: ${a1}");
    }
}

test_json_mapper() {
  {
    print(">>1 test_toJson");
    String json = test_toJson(createExpense());
  
    print(">>1 test_fromJson");
    Expense e = test_fromJson(Expense, json);
  }
  {
    print(">>2 test_fromJson");
    Expense e = test_fromJson(Expense, json1);
   
    print(">>2 test_toJson");
    String json = test_toJson(e);
  }  
  {
    print(">>3 test_fromJson");
    // since we cannot write 'test_fromJson(List<Expense>()), '[${json1},${json2}]')', we need to do this..
    // but this is OK when we run dirtVM,. but not ossible on client(browser)
//    List<Expense> es = test_fromJson(new List<Expense>().runtimeType, '[${json1},${json2}]');
    // only to level, use Expense instead of ist<Expense>, or new List<Expense>().runtimeType
    // since there is a Dart mirror lib bug(problem)
    List<Expense> es = test_fromJson(Expense, '[${json1},${json2}]');
   
    print(">>3 test_toJson");
    String json = test_toJson(es);
  }

}

