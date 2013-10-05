library sample_server_app;

import "package:couchdb/server/CouchDbDAO.dart";
import "package:portable_mirror/mirror_dynamic_lib.dart";

import "../lib/src/models.dart";
import "../lib/src/sample_json_mapper.dart";

//
final String couchdb_host = "localhost";
final int couchdb_port = 5984;

final String http_server_host = "localhost";
final int http_server_port = 8080;

final String dbName = "expensedb";

main() {

  // register reflection factory
  initClassMirrorFactory();
  
//  log.onRecord.listen(new SyncFileLoggingHandler("dart_server.log"));
//  log.info("========================\n");
  print('start test');
  //IClassMirror cmirror = ClassMirrorFactory.reflectClass(Expense);  
  CouchDbDAO<Expense> dbHandler = new CouchDbDAO<Expense>(Expense, sampleJsonMapper, couchdb_host, couchdb_port, dbName);

//  dbHandler.getData("/$dbName/", method:'PUT');
    //
  test0() {
    var json0 = '{"id":null, "amount":2.0,"expenseType":{"name":"Hotel","code":"HT"},"date":"2013-09-06 00:00:00.000","detail":"kkk","isClaimed":false}';
    Expense expense = sampleJsonMapper.fromJson(Expense, json0);
    dbHandler.insert(expense)
      .then((Expense e){
        //log.info(">>>>>  addOrUpdate: ${e.toJson()}");
        print(">>>>>  insert: ${sampleJsonMapper.toJson(e)}");
        return true;
    }).then((_){
      dbHandler.getAll().then((List<Expense> es){
        //
        print(">>>>>  getAll: ");
        es.forEach((e0) { print(">>>>>  e0: ${e0}"); });
        print('finished test');
      });
    });
  }
  
  test1() {
    // get revision nemer using http://localhost:5984/_utils, and update the rev of json1
    var json1 = '{"id":"1d1a636bdd03d0ec510d84d0890021a2","date":"2013-09-06 00:00:00.000","amount":2.0,"detail":"kkk??","isClaimed":false,"expenseType":{"name":"Hotel","code":"HT"},"rev":"2-7258b84b5bdf88be0e5807c8d2643b34"}';
//    var json1 = '{"id":"1d1a636bdd03d0ec510d84d0890021a2","date":"2013-09-06 00:00:00.000","amount":2.0,"detail":"kkk","isClaimed":false,"expenseType":{"name":"Hotel","code":"HT"}}';
    print("@@@>>>>> test1 update: json1: ${json1}");
    
    Expense expense = sampleJsonMapper.fromJson(Expense, json1);
    dbHandler.update(expense)
      .then((Expense e){
        //log.info(">>>>>  addOrUpdate: ${e.toJson()}");
        print("@@@>>>>> test1 update: e: ${e}, json: ${sampleJsonMapper.toJson(e)}");
        return true;
    }).then((_){
      /*
      dbHandler.getAll().then((List<Expense> es){

        print(">>>>>  getAll: ");
        es.forEach((e0) { print(">>>>>  e0: ${e0}"); });
        print('finished test');
      });
      */
    });;
  }
  
  test1();
}

