library sample_server_app;

import "package:couchdb/server/CouchDbHttpServer.dart";
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


void main() {

  // register reflection factory
  initClassMirrorFactory();
  
  CouchDbDAO<Expense> couchDbDAO = new CouchDbDAO<Expense>(Expense, sampleJsonMapper, couchdb_host, couchdb_port, dbName);
  
  CouchDbHttpServer server = new CouchDbHttpServer(couchDbDAO);
  
  server.startHttpServer(http_server_host, http_server_port);
  
  print(">> SampleServer started.");
}

json_mapper_test() {
  var json1 = '{"id":"1d1a636bdd03d0ec510d84d0890021a2","date":"2013-09-06 00:00:00.000","amount":2.0,"detail":"kkk","isClaimed":false,"expenseType":{"name":"Hotel","code":"HT"},"rev":"1-b7735139a104d425bb57423911cca461"}';
  Expense exp = sampleJsonMapper.fromJson(Expense, json1);
  print('----> exp: ${exp}');
}

couchdb_test() {
//  log.onRecord.listen(new SyncFileLoggingHandler("dart_server.log"));
//  log.info("========================\n");
  print('start test');
  //IClassMirror cmirror = ClassMirrorFactory.reflectClass(Expense);  
  CouchDbDAO<Expense> dbHandler = new CouchDbDAO<Expense>(Expense, sampleJsonMapper, couchdb_host, couchdb_port, dbName);

//  dbHandler.getData("/$dbName/", method:'PUT');
  var json1 = {"id": "cb79a73fe1c504ee847e60801e00733f","rev": "1-6d0a6edeca881b69a734261ecaa13ec6","expenseType": {"name": "Travel", "code": "TRV"},"date": "2013-10-02 00:00:00.000","amount": 333,"detail": "ddddd","isClaimed": false};
    Expense expense = sampleJsonMapper.fromJson(Expense, '{"id":null, "amount":2.0,"expenseType":{"name":"Hotel","code":"HT"},"date":"2013-09-06 00:00:00.000","detail":"kkk","isClaimed":false}');
    dbHandler.insert(expense)
      .then((Expense e){
        //log.info(">>>>>  addOrUpdate: ${e.toJson()}");
        print(">>>>>  addOrUpdate: ${sampleJsonMapper.toJson(e)}");
        dbHandler.getAll().then((List<Expense> es){
          //
          print(">>>>>  getAll: ");
          es.forEach((e0) { print(">>>>>  e0: ${e0}"); });
          print('finished test');
        });
    });
}

