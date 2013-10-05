part of couchdb_client;

typedef void SyncEntity(dynamic e, String opType);

String couchdb_httpsrv_host = "127.0.0.1";
String couchdb_httpsrv_port = "8080";

class CouchDbClientDAO<T> implements ICouchDbClientDAO<T> {
  static String url = "http://${couchdb_httpsrv_host}:${couchdb_httpsrv_port}";
  final Type modelType;
  final IJsonMapper jsonMapper;
  final bool debug = false;
   
  CouchDbClientDAO(this.modelType, this.jsonMapper);
  
  Future<List<T>> fetchAll() =>
      HttpRequest.request('${url}/fetchAll').then(
          (HttpRequest req) {
            if (debug) print(">> CouchDbClientDAO<1>　fetchAll req.responseText: ${req.responseText}");
            return jsonMapper.fromJson(modelType, req.responseText);
          }
      );
  Future<T> insert(T e) =>
      HttpRequest.request('${url}/insert', method: "POST", sendData: jsonMapper.toJson(e)).then(
          (HttpRequest req) {
            if (debug) print(">> CouchDbClientDAO<1>　insert req.responseText: ${req.responseText}");
            return jsonMapper.fromJson(modelType, req.responseText);
          }
      );
 Future<T> update(T e) {
      if (debug) print('@@@@@CouchDbClientDAO e: ${e} json: ${jsonMapper.toJson(e)}');
      return HttpRequest.request('${url}/update', method: "POST", sendData: jsonMapper.toJson(e)).then(
          (HttpRequest req) {
            if (debug) print(">> CouchDbClientDAO<1>　update req.responseText: ${req.responseText}");
            return jsonMapper.fromJson(modelType, req.responseText);
          }
      );
 }
 Future<bool> delete(T e) =>
    HttpRequest.request('${url}/delete', method: "POST", sendData: jsonMapper.toJson(e)).then(
        (HttpRequest req) {
          if (debug) print(">> CouchDbClientDAO delete<1>　delete req.responseText: ${req.responseText}");
          //_delete(e);
          return true;
        }
    );
}
