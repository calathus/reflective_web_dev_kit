library couchdb;

import "dart:io";
import "dart:json";
import "dart:async";
import "dart:convert";

import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

import 'couchdb_utils.dart';
import "package:json_mapper/json_mapper_v1.dart";

typedef void onError(Object e);
typedef Future<HttpClientResponse> HttpClientResponseAction(HttpClientRequest req);
typedef dynamic FromJsonMap(Map map); // dynamic should be replace by T!!

/*
class CouchDBFetchData<T> {
  List<CouchDBFetchRowData<T>> _rows;
  
  List<CouchDBFetchRowData<T>> get rows => _rows;
  void set rows( List<CouchDBFetchRowData<T>> rows) { _rows = rows; }
}

class CouchDBFetchRowData<T> {
  T _doc;
  T get doc => _doc;
  void set doc(T doc) { _doc = doc; }
}
*/

class CouchDbDAO<T> {
  static final Logger log = _logger() ;
  static Logger _logger() {
    Logger log = new Logger('couchdb.log');// the file nam eseems not required!!
    log.onRecord.listen(new SyncFileLoggingHandler("couchdb.log"));
    log.info("========================\n");
    return log;
  }
  final Type modelType;
  final IJsonMapper jsonMapper;
  final host;
  final port;
  final dbName;
  final HttpClient client;

  CouchDbDAO(this.modelType, this.jsonMapper, this.host, this.port, this.dbName): this.client = new HttpClient() {
     _tryCreateDb();
  }
  // this is not working due to Dart VM bug. but it will be fixed soon..
  /*
  Future<List<T>> getAll() {
    return _getData("/$dbName/_all_docs?include_docs=true")
        .then( (json) {
          if (json != "") {
            print(">>>>>0 getAll: ${new CouchDBFetchData<T>().runtimeType}");
            print(">>>>>1 getAll: ${json} ");
            CouchDBFetchData<T> data = jsonMapper.fromJson(new CouchDBFetchData<T>().runtimeType, json, attr_redirect_map: {'id':'_id', 'rev':'_rev'});
            List<T> ts = data.rows.fold([], (list, CouchDBFetchRowData<T> row)=>list..add(row.doc));
            print(">>>>>2 getAll: ${ts}");
            return ts;
            /*
            Map data = parse(json); // temp
            for (var rowData in data["rows"]) {
              Map map = rowData["doc"];
              // [WARNING] here CouchDB uses '_id' instead of 'id'!
              // json mapper shoudl be able to handle this replacement through annotation(see Dartson)
              map['id'] = map['_id'];
              map.remove('_id');
              map['rev'] = map['_rev'];
              map.remove('_rev');
              String json1 = stringify(map); // temp
              T t = jsonMapper.fromJson(modelType, json1); // [nc] be careful!! this may requires modelType instead of T!!!!!
              ts.add(t);
              */
          } else {
            return new List<T>();
          }
        }).catchError((_)=>[]); // when it is empty, error will be thrown...
  }
  */

  Future<List<T>> getAll() {
    print(">>>>>0 getAll:  ");
    return _getData("/$dbName/_all_docs?include_docs=true")
        .then( (json) {
          print(">>>>>1 getAll: ${json} ");
          List<T> ts = new List<T>();
          if (json != "") {
            Map data = parse(json); // temp
            for (var rowData in data["rows"]) {
              Map map = rowData["doc"];
              // [WARNING] here CouchDB uses '_id' instead of 'id'!
              // json mapper shoudl be able to handle this replacement through annotation(see Dartson)
              map['id'] = map['_id'];
              map.remove('_id');
              map['rev'] = map['_rev'];
              map.remove('_rev');
              String json1 = stringify(map); // temp
              print(">>>>>2 getAll: ${json1} ");
              T t = jsonMapper.fromJson(modelType, json1); // [nc] be careful!! this may requires modelType instead of T!!!!!
              print(">>>>>3 getAll: ${t} ");
              ts.add(t);
            }
          }
          return ts;
        }).catchError((_)=>[]); // when it is empty, error will be thrown...
  }
  
  Future<T> insert(T t) {
    log.info(">> insert json: ${jsonMapper.toJson(t)}");
    return _getData('/$dbName', method: 'POST', data: jsonMapper.toJson(t)).then((String json){
      log.info("==>> CouchDbDAO<1> insert: json: $json");
      Map map = parse(json); // temp
      if (map['ok']) {
        ICouchDoc cdoc = new CouchDoc<T>(modelType, t);
        cdoc.id = map["id"]; // <==
        cdoc.rev = map["rev"];
        log.info("==>> CouchDbDAO<2> insert: exp: ${jsonMapper.toJson(t)}");
        return t;
      } else {
        return null;
      }
    });
  }
  
  Future<T> update(T t) {
    log.info(">> update t: ${jsonMapper.toJson(t)}");
    ICouchDoc cdoc = new CouchDoc<T>(modelType, t);
    String up_json = jsonMapper.toJson(t);
    Map data = parse(up_json); // temp
    data['_id'] = data['id'];
    data.remove('id');
    data['_rev'] = data['rev'];
    data.remove('rev');
    return _getData('/$dbName/${cdoc.id}', method: 'PUT', data: stringify(data)).then((String json){
      log.info("==>> CouchDbDAO<1> update: json: $json");
      Map map = parse(json); // temp
      var ok = map['ok'];
      if (ok != null && ok) {
        cdoc.id = map["id"]; // should be teh same 
        cdoc.rev = map["rev"]; // get different revision number!! so this is required.
        log.info("==>> CouchDbDAO<2> update: exp: ${jsonMapper.toJson(t)}");
        return t;
      } else {
        log.info("==>> CouchDbDAO<2> update failed: reason: ${json}");
        return null;
      }
      return t;
    });
  }
 
  Future<T> delete(T t) {
    //ICouchDoc t = t0; //duck typing..
    log.info("delete data");
    ICouchDoc cdoc = new CouchDoc<T>(modelType, t);
    String idv = cdoc.id;
    String revv = cdoc.rev;
    return _getData('/$dbName/${idv}?rev=${revv}', method: 'DELETE').then((String responseText){
      log.info("==>> DELETE CouchDbDAO<1> delete: responseText: $responseText");
      return t;
    });
  }

  Future<bool> existDb() {
    log.info("existDB");
    return _getData("/_all_dbs").then( (responseText) {
      log.info(">>existDB<1> $responseText");
      List<String> dbNames = parse(responseText);
      return dbNames.contains(dbName);
    });
  }
  
  Future createDb() =>_getData("/$dbName/", method:'PUT');
 
  //
  //
  _tryCreateDb() {
    log.info("creatingDb");
    existDb().then((bool exist){
      log.info("_tryCreateDb exist: $exist");
      if (!exist) {
        createDb();
      }
    });
  }
  HttpClientResponseAction _writeData(String data) =>
    (HttpClientRequest request) {
      //
      request.headers.add('Content-Type', 'application/json');
      log.info("_writeData data: $data");
      if (data != null) {
        request.write(data);
      }
      return request.close(); 
    };

  Future<String> getData(String path, {String method: 'GET', String data: null}) {
      return _getData(path, method: method, data: data);
  }
  Future<String> _getData(String path, {String method: 'GET', String data: null}) {
    log.info("_getData $method: $path ${method} ${data}");
    return getAsStringFromResponse(client.open(method, host, port, path).then(_writeData(data)));
  }
 
  Future<String> _putData(String path, String data) {
    return _getData(path, method: 'PUT', data: data);
  }
  
  // should not include id in path!
  Future<String> _postData(String path, String data) {
    log.info("_putData: $path ${data}");
    return _getData(path, method: 'POST', data: data);
  }
  
  Future<String> getAsStringFromResponse(Future<HttpClientResponse> fu_res) =>
    fu_res
      .then((HttpClientResponse resp) => resp.transform(new Utf8Decoder())
        .fold(new StringBuffer(), (buf, line) {buf.write(line); return buf;}))
      .then((StringBuffer buf) => buf.toString());
}