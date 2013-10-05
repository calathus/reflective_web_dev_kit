library couchdb_proxy;

import "dart:io";
import "dart:async";

import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

import 'CouchDbDAO.dart';
import "package:json_mapper/json_mapper_v1.dart";

abstract class IHttpReqHandler {
  bool matcher(HttpRequest req);
  void action(HttpRequest req);
}

typedef bool HttpRequestMatcher(HttpRequest req);
typedef bool HttpRequestAction(HttpRequest req);

class CouchDbHttpReqHandler implements IHttpReqHandler {
  HttpRequestMatcher _matcher;
  HttpRequestAction _action;
  
  CouchDbHttpReqHandler(this._matcher, this._action);
  
  bool matcher(HttpRequest req)=>_matcher(req);
  void action(HttpRequest req) { _action(req); }
}

typedef dynamic FromJson(String s);
typedef String ToJson(dynamic t);

class CouchDbHttpServer<T> {
  static Logger log = _logger();
  
  static Logger _logger() {
    Logger log = new Logger('httpserver.log');// the file nam eseems not required!!
    log.onRecord.listen(new SyncFileLoggingHandler("couchdb_proxy.log"));
    log.info("========================\n");
    return log;
  }

  CouchDbDAO<T> _dao;
  
  List<IHttpReqHandler> reqHandlers;

  IHttpReqHandler load;
  IHttpReqHandler insert;
  IHttpReqHandler update;
  IHttpReqHandler delete;
  
  CouchDbHttpServer(this._dao) {

    load = new CouchDbHttpReqHandler(
  
    (HttpRequest req) {
      var path = req.uri.path;
      log.info("LoadDataHandler GET: $path");
      return path.startsWith("/fetchAll");
    },

    (HttpRequest req) {
      log.info(">>>> CouchDbHttpReqHandler load");
      HttpResponse res = req.response;
      _dao.getAll().then((List<T> es) {
        log.info("loaded entities: $es");
        String json = jsonMapper.toJson(es);
        res.write(json);
        res.close();
      });
    });

    insert = new CouchDbHttpReqHandler(
        
    (HttpRequest req) {
      var path = req.uri.path;
      log.info("CouchDbHttpReqHandler PUT: $path");
      return path.startsWith("/insert");
    },

    (HttpRequest req) {
      log.info(">>>> CouchDbHttpReqHandler insert");
      HttpResponse res = req.response;
      req.listen((List<int> buffer) {
        String json = new String.fromCharCodes(buffer);
        log.info("CouchDbHttpReqHandler jsonString: $json");

        T e = jsonMapper.fromJson(modelType, json);
        _dao.insert(e).then((T e1){
          log.info("CouchDbHttpReqHandler _dao.insert: $e1");
          res.write(jsonMapper.toJson(e1));
          res.close();
        });
      });
    });
    
    update = new CouchDbHttpReqHandler(
        
    (HttpRequest req) {
      var path = req.uri.path;
      log.info("CouchDbHttpReqHandler PUT: $path");
      return path.startsWith("/update");
    },

    (HttpRequest req) {
      log.info(">>>> CouchDbHttpReqHandler update");
      HttpResponse res = req.response;
      req.listen((List<int> buffer) {
        String json = new String.fromCharCodes(buffer);
        log.info("CouchDbHttpReqHandler jsonString: $json");

        T e = jsonMapper.fromJson(modelType, json);
        _dao.update(e).then((T e1){
          log.info("CouchDbHttpReqHandler _dao.update: $e1");
          res.write(jsonMapper.toJson(e1));
          res.close();
        });
      });
    });

    delete = new CouchDbHttpReqHandler(
  
      (HttpRequest req) {
        var path = req.uri.path;
        log.info("DeleteReqHandler PUT: $path");
        return path.startsWith("/delete");
      },

      (HttpRequest req) {
        log.info(">>>> CouchDbHttpReqHandler delete");
        HttpResponse res = req.response;
        req.listen((List<int> buffer) {
          var json = new String.fromCharCodes(buffer);
          log.info("CouchDbHttpReqHandler json: $json");
          T e = jsonMapper.fromJson(modelType, json);
          _dao.delete(e).then((T e1){
            log.info("CouchDbHttpReqHandler _dao.delete: $e1");
            res.write(jsonMapper.toJson(e1));
            res.close();
          });
        });
      });
    
    this.reqHandlers = [load, insert, update, delete];
  }
  
  IJsonMapper get jsonMapper => _dao.jsonMapper;
  Type get modelType => _dao.modelType;
  
  Future<StreamSubscription> startHttpServer(String host, int port) =>
    HttpServer.bind(host, port)
      .then((HttpServer server) =>
          server.listen((HttpRequest req) {
            HttpResponse res = req.response;
            res.headers.add("Access-Control-Allow-Origin", "*");
            res.headers.add("Access-Control-Allow-Credentials", true);
            
            bool done = false;
            for (IHttpReqHandler h in reqHandlers) {
              if (h != null && h.matcher(req)) {
                h.action(req);
                done = true;
                break;
              }
            }
            if (!done) {
              log.info("got 404 for ${req.uri}");
              req.response.statusCode = 404;
              req.response.close();
            }
          }, onError: (e) {
            log.info("startHttpServer got error for ${e}");
          })
      );
}
